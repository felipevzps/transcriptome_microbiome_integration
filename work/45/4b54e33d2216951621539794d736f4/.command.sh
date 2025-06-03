#!/bin/bash -ue
python3 - <<EOF
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Load correlation matrix
df = pd.read_csv("otu_gene_correlation.tsv", sep="\t", index_col=0)

# Convert all values to numeric, coerce errors (like 'nan' strings)
df = df.apply(pd.to_numeric, errors='coerce')

# Create heatmap
plt.figure(figsize=(12, 10))
sns.heatmap(df, cmap="coolwarm", center=0, linewidths=0.5, linecolor='gray')

plt.title("OTU vs Gene Expression Correlation Heatmap")
plt.xlabel("Genes")
plt.ylabel("OTUs")
plt.tight_layout()

# Save PNG
plt.savefig("otu_gene_heatmap.png", dpi=300)
EOF
