#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.otu_table = null
params.expression_matrix = null
params.output_dir = "./results"

process correlateOtuExpression {

    tag "Correlating OTUs and gene expression"
    publishDir "${params.output_dir}", mode: 'copy'

    input:
    path otu_table
    path expression_matrix

    output:
    path("otu_gene_correlation.tsv")

    script:
    """
    python3 - <<EOF
import pandas as pd
import numpy as np
from scipy.stats import pearsonr

# Load input
otu_df = pd.read_csv("${otu_table}", sep="\\t").set_index("OTU_ID")
expr_df = pd.read_csv("${expression_matrix}", sep="\\t").set_index("Name")

# Find common samples
common_samples = list(set(otu_df.columns).intersection(expr_df.columns))
otu_df = otu_df[common_samples].T
expr_df = expr_df[common_samples].T

# Log2 transform (pseudo count +1 to avoid log(0))
otu_df = np.log2(otu_df + 1)
expr_df = np.log2(expr_df + 1)

# Remove features with low variance
otu_df = otu_df.loc[:, otu_df.std() > 0.01]
expr_df = expr_df.loc[:, expr_df.std() > 0.01]

# Compute correlation
correlation_df = pd.DataFrame(index=otu_df.columns, columns=expr_df.columns)

for otu in otu_df.columns:
    for gene in expr_df.columns:
        try:
            corr, _ = pearsonr(otu_df[otu], expr_df[gene])
            correlation_df.at[otu, gene] = corr
        except:
            correlation_df.at[otu, gene] = np.nan

# Save correlation matrix
correlation_df.to_csv("otu_gene_correlation.tsv", sep="\\t")
EOF
    """
}

process plotHeatmap {

    tag "Plotting correlation heatmap"
    publishDir "${params.output_dir}", mode: 'copy'

    input:
    path correlation_matrix

    output:
    path("otu_gene_heatmap.png")

    script:
    """
    python3 - <<EOF
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Load correlation matrix
df = pd.read_csv("${correlation_matrix}", sep="\\t", index_col=0)

# Convert to numeric and drop all-NaN rows/columns
df = df.apply(pd.to_numeric, errors='coerce')
df = df.dropna(axis=0, how='all')
df = df.dropna(axis=1, how='all')

# Print stats for debug
print("Matrix shape:", df.shape)
print("Min:", df.min().min())
print("Max:", df.max().max())
print("Mean:", df.mean().mean())
print("Non-NaN values:", df.notna().sum().sum())

# Skip if empty
if df.empty:
    print("Filtered matrix is empty — no heatmap generated.")
else:
    plt.figure(figsize=(12, 10))
    sns.heatmap(
        df,
        cmap="coolwarm",
        linewidths=0.5,
        linecolor='gray',
        cbar_kws={'label': 'Pearson r'}
        # Removed vmin and vmax to allow automatic scaling
    )
    plt.title("OTU vs Gene Expression Correlation Heatmap")
    plt.xlabel("Genes")
    plt.ylabel("OTUs")
    plt.tight_layout()
    plt.savefig("otu_gene_heatmap.png", dpi=300)
EOF
    """
}

workflow {

    if (!params.otu_table || !params.expression_matrix) {
        error "Missing required parameters: --otu_table and --expression_matrix"
    }

    correlateOtuExpression_out = correlateOtuExpression(
        file(params.otu_table),
        file(params.expression_matrix)
    )

    plotHeatmap(correlateOtuExpression_out)
}
