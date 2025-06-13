#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process merge_otu {
    tag "Merging OTU tables"

    input:
    tuple path(day_file)
    path day_file
    path night_file
    val output_dir

    output:
    path("merged_otu_table.tsv"), emit: out

    publishDir "${output_dir}", mode: 'copy'

    script:
    """
    python3 - <<EOF
import pandas as pd

day_df = pd.read_csv("${day_file}", sep='\\t')
night_df = pd.read_csv("${night_file}", sep='\\t')

day_df = day_df.rename(columns={col: f"exp_day_{col}" for col in day_df.columns if col != "OTU_ID"})
night_df = night_df.rename(columns={col: f"exp_night_{col}" for col in night_df.columns if col != "OTU_ID"})

merged_df = pd.merge(day_df, night_df, on="OTU_ID", how='outer')

merged_df.to_csv("merged_otu_table.tsv", sep='\\t', index=False)
EOF
    """
}


