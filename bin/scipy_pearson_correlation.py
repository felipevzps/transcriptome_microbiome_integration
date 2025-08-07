#!/usr/bin/env python3

import argparse
import pandas as pd
import numpy as np
import sys
from scipy.stats import pearsonr

parser = argparse.ArgumentParser(description='Calculate Pearson Correlation')
parser.add_argument('--otu', type=str, dest='otu_table', help='OTU table file', metavar='otu_table.tsv', required=True)
parser.add_argument('--expr', type=str, dest='expr_file', help='expression matrix file', metavar='expression_matrix.tsv', required=True)
parser.add_argument('--output', type=str, dest='otu_gene_correlation_out', help='OTU gene correlation output', metavar='otu_gene_correlation.tsv', required=True)
args = parser.parse_args()

otu_table = args.otu_table
expr_file = args.expr_file 
output = args.otu_gene_correlation_out

otu_df  = pd.read_csv(otu_table,  sep="\t").set_index("OTU_ID")
expr_df = pd.read_csv(expr_file, sep="\t").set_index("Name")

common = list(set(otu_df.columns) & set(expr_df.columns))
if len(common) < 2:
    print("Not enough common samples (found {})".format(len(common)))
    pd.DataFrame().to_csv(output, sep="\t")
    sys.exit(0)

otu_df  = np.log2(otu_df[common].T + 1)
expr_df = np.log2(expr_df[common].T + 1)

otu_df  = otu_df.loc[:, otu_df.std() > 0.01]
expr_df = expr_df.loc[:, expr_df.std() > 0.01]

if otu_df.empty or expr_df.empty:
    print("No features after variance filter")
    pd.DataFrame().to_csv(output, sep="\t")
    sys.exit(0)

corr = pd.DataFrame(index=otu_df.columns, columns=expr_df.columns, dtype=float)
for o in otu_df.columns:
    for g in expr_df.columns:
        corr.at[o, g] = pearsonr(otu_df[o], expr_df[g])[0]

corr.to_csv(output, sep="\t")
