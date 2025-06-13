process correlateOtuExpression {

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
    echo "Step 1: Prepare combined matrix with common samples"

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
print("Found {} common samples.".format(len(common_samples)))

if len(common_samples) < 2:
    print("Not enough common samples.")
    pd.DataFrame().to_csv("sparcc_correlation.tsv", sep="\\t")
    sys.exit(0)

otu_df = otu_df[common_samples].T + 1
expr_df = expr_df[common_samples].T + 1

combined_df = pd.concat([otu_df, expr_df], axis=1)
combined_df = combined_df.astype(float)

combined_df.to_csv("combined.tsv", sep="\\t", index=False, header=False)

with open("header.txt", "w") as f:
    f.write("\\t".join(combined_df.columns) + "\\n")

print("Combined matrix shape:", combined_df.shape)
EOF

    echo "Step 2: Running FastSpar..."
    fastspar \\
        --otu_table combined.tsv \\
        --correlation fastspar_output.tsv \\
        --covariance fastspar_cov.tsv \\
        --threads ${task.cpus}

    status=\$?
    if [ \$status -ne 0 ]; then
        echo " FastSpar failed with status \$status"
        exit 1
    fi

    echo "Step 3: Add header to correlation matrix"
    cat header.txt fastspar_output.tsv > sparcc_correlation.tsv

    echo "Step 4: Generate heatmap"
    python3 - <<EOF
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

df = pd.read_csv("sparcc_correlation.tsv", sep="\\t", index_col=0)
plt.figure(figsize=(12, 10))
sns.heatmap(df, cmap='vlag', center=0, xticklabels=True, yticklabels=True)
plt.title("SparCC Correlation Heatmap")
plt.tight_layout()
plt.savefig("sparcc_heatmap.png", dpi=300)
EOF

    echo "Outputs generated:"
    ls -lh sparcc_correlation.tsv sparcc_heatmap.png
    """
}
