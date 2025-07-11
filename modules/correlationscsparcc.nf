process correlationscsparcc {

    tag 'sparcc_fastspar'
    cpus 4

    publishDir params.output_dir, mode: 'copy'

    input:
        path otu_table
        path expression_matrix

    output:
        path 'sparcc_correlation.tsv' emit: sparcc_correlation_file
        path 'sparcc_heatmap.png' emit: sparcc_heatmap_file

    script:
    """
    echo "Step 1: Prepare combined matrix"

    python3 - <<EOF
import pandas as pd
import numpy as np
import sys

try:
    otu_df  = pd.read_csv("${otu_table}", sep="\\t").set_index("OTU_ID")
    expr_df = pd.read_csv("${expression_matrix}", sep="\\t").set_index("Name")
except Exception as e:
    print("Error reading input files:", e)
    sys.exit(1)

common_samples = sorted(set(otu_df.columns) & set(expr_df.columns))
print(f"Found {len(common_samples)} common samples: {common_samples}")

if len(common_samples) < 2:
    print("Not enough common samples.")
    pd.DataFrame().to_csv("sparcc_correlation.tsv", sep="\\t")
    sys.exit(0)

otu_df = otu_df[common_samples].T + 1
expr_df = expr_df[common_samples].T + 1

combined_df = pd.concat([otu_df, expr_df], axis=1)
combined_df = combined_df.astype(float)

combined_df.to_csv("combined.tsv", sep="\\t", index=False, header=False)

with open("colnames.txt", "w") as f:
    f.write("\\t".join(combined_df.columns) + "\\n")
EOF

    echo "Step 2: Running FastSpar"
    fastspar \\
        --otu_table combined.tsv \\
        --correlation fastspar_output.tsv \\
        --covariance fastspar_cov.tsv \\
        --threads ${task.cpus}

    if [ ! -s fastspar_output.tsv ]; then
        echo "FastSpar output is empty or missing."
        touch sparcc_correlation.tsv
        exit 0
    fi

    echo "Step 3: Reformat FastSpar output"
    python3 - <<EOF
import pandas as pd
import sys

df = pd.read_csv("fastspar_output.tsv", sep="\\t", header=None)

with open("colnames.txt") as f:
    labels = f.read().strip().split("\\t")

if df.shape[0] != len(labels) or df.shape[1] != len(labels):
    print(f"Shape mismatch: data {df.shape}, labels {len(labels)}")
    df.to_csv("sparcc_correlation.tsv", sep="\\t")
    sys.exit(0)

df.columns = labels
df.index = labels
df.to_csv("sparcc_correlation.tsv", sep="\\t")
EOF

    echo "Step 4: Generate heatmap"
    python3 - <<EOF
import pandas as pd
import seaborn as sns
import matplotlib
matplotlib.use("Agg")  # ✅ Force headless rendering
import matplotlib.pyplot as plt
import os
import sys

try:
    df = pd.read_csv("sparcc_correlation.tsv", sep="\\t", index_col=0)
except Exception as e:
    print("Error reading correlation file:", e)
    sys.exit(1)

if df.empty or df.shape[0] < 2:
    print("Correlation matrix is empty or too small.")
    sys.exit(0)

# Convert to numeric and clean up
df = df.apply(pd.to_numeric, errors="coerce")
df = df.fillna(0)

print(f"Final matrix shape: {df.shape}")
print(df.iloc[:5, :5])

plt.figure(figsize=(12, 10))
sns.heatmap(df, cmap="vlag", center=0, xticklabels=True, yticklabels=True)
plt.title("SparCC Correlation Heatmap")
plt.tight_layout()
plt.savefig("sparcc_heatmap.png", dpi=300)

if not os.path.exists("sparcc_heatmap.png"):
    print("Heatmap was not created.")
    sys.exit(1)
else:
    print("Heatmap successfully saved.")
EOF

    echo "Done. Outputs:"
    ls -lh sparcc_correlation.tsv sparcc_heatmap.png || true
    """
}
