#!/usr/bin/env nextflow

process mergeOtuTables {
    tag "Merging OTU tables"

    input:
    path day_file
    path night_file

    output:
    path "merged_otu_table.tsv"

    script:
    """
    python3 - <<EOF

import pandas as pd

#Read inputs 
day_df = pd.read_csv("${day_file}",sep='\\t')
night_df = pd.read_csv("${night_file}", sep='\\t')

#Add prefixes
day_df= day_df.renname(coloumns={col:f"exp_day_{col}" for col in day_df.columns if col !="OTU_ID"})
night_df= nigth_df.rename(columns={col:f"exp_night_{col}" for col in night_df.columns if col != "OTU_ID"})

#Merge
merged_df= pd.merge(day_df,night_df on='OTU_ID', how='outer')

#Save
merged_df.to_csv("merged_otu_table.tsv", sep='\\t', index=False)
EOF 
     """
}