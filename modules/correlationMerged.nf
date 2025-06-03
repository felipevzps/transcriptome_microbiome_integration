#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

/*******************************************************************
 *                      WORKFLOW DEFINITION
 *******************************************************************/
workflow {
    otu_ch  = Channel.fromPath(params.otu_table)
    expr_ch = Channel.fromPath(params.expression_matrix)

    correlateOtuExpression(otu_ch, expr_ch) | plotHeatmap
}

/*******************************************************************
 *                           PROCESSES
 *******************************************************************/
process correlateOtuExpression {

    tag 'correlate'

    publishDir params.output_dir, mode: 'copy'

    input:
        path otu_table
        path expression_matrix

    output:
        path 'otu_gene_correlation.tsv'

    script:
    """
    python3 - <<'EOF'
import pandas as pd
import numpy as np
from scipy.stats import pearsonr
import sys

# 1. Read OTU and expression tables
otu_df  = pd.read_csv("${otu_table}",  sep="\\t").set_index("OTU_ID")
expr_df = pd.read_csv("${expression_matrix}", sep="\\t").set_index("Name")

# 2. Find common samples
common = list(set(otu_df.columns) & set(expr_df.columns))
if len(common) < 2:
    print("Not enough common samples (found {})".format(len(common)))
    pd.DataFrame().to_csv("otu_gene_correlation.tsv", sep="\\t")
    sys.exit(0)

# 3. Log2-transform with pseudocount
otu_df  = np.log2(otu_df[common].T + 1)
expr_df = np.log2(expr_df[common].T + 1)

# 4. Variance filters
otu_df  = otu_df.loc[:, otu_df.std() > 0.01]
expr_df = expr_df.loc[:, expr_df.std() > 0.01]

if otu_df.empty or expr_df.empty:
    print("No features after variance filter")
    pd.DataFrame().to_csv("otu_gene_correlation.tsv", sep="\\t")
    sys.exit(0)

# 5. Compute Pearson correlations
corr = pd.DataFrame(index=otu_df.columns, columns=expr_df.columns, dtype=float)
for o in otu_df.columns:
    for g in expr_df.columns:
        corr.at[o, g] = pearsonr(otu_df[o], expr_df[g])[0]

corr.to_csv("otu_gene_correlation.tsv", sep="\\t")
EOF
    """
}


process plotHeatmap {

    tag 'heatmap'

    publishDir params.output_dir, mode: 'copy'

    input:
        path correlation_matrix  // this will be `otu_gene_correlation.tsv`

    output:
        path 'correlation_heatmap.png'

    script:
    """
    python3 - << 'EOF'
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Read the correlation matrix
corr = pd.read_csv("${correlation_matrix}", sep="\\t", index_col=0)

# Plot heatmap
plt.figure(figsize=(10, 8))
sns.heatmap(corr, cmap="vlag", center=0)
plt.title("OTU–Gene Pearson Correlation Heatmap")
plt.tight_layout()
plt.savefig("correlation_heatmap.png")
EOF
    """
}

