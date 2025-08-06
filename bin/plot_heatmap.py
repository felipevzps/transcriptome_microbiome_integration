#!/usr/bin/env python3

import argparse
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

parser = argparse.ArgumentParser(description='Plot OTU-Gene Pearson Correlation Heatmap')
parser.add_argument('--corr', type=str, dest='correlation_matrix', help='correlation matrix file', metavar='correlation_matrix.tsv', required=True)
parser.add_argument('--output', type=str, dest='heatmap_correlation_out', help='OTU-Gene correlation heatmap', metavar='correlation_heatmap.png', required=True)
args = parser.parse_args()  

input_matrix = args.correlation_matrix
output = args.heatmap_correlation_out

corr = pd.read_csv(input_matrix, sep="\t", index_col=0)

plt.figure(figsize=(10, 8))
sns.heatmap(corr, cmap="vlag", center=0)
plt.title("OTU–Gene Pearson Correlation Heatmap")
plt.tight_layout()
plt.savefig(output)
