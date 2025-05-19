#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.day_file     = null
params.night_file   = null
params.output_dir   = "./results"

process mergeOtuTables {

    tag "Merging OTU tables"

    publishDir "${output_dir}", mode: 'copy'

    input:
    path day_file
    path night_file
    val output_dir

    output:
    path("merged_otu_table.tsv")

    script:
    """
    python3 - <<EOF
import pandas as pd

# Read input files
day_df = pd.read_csv("${day_file}", sep='\\t')
night_df = pd.read_csv("${night_file}", sep='\\t')

# Rename columns except OTU_ID
day_df = day_df.rename(columns={col: f"exp_day_{col}" for col in day_df.columns if col != "OTU_ID"})
night_df = night_df.rename(columns={col: f"exp_night_{col}" for col in night_df.columns if col != "OTU_ID"})

# Merge
merged_df = pd.merge(day_df, night_df, on="OTU_ID", how='outer')

# Save output
merged_df.to_csv("merged_otu_table.tsv", sep='\\t', index=False)
EOF
    """
}

workflow {

    if (!params.day_file || !params.night_file || !params.output_dir) {
        error "Missing required parameters: --day_file, --night_file, or --output_dir"
    }

    mergeOtuTables(
        file(params.day_file),
        file(params.night_file),
        params.output_dir
    )
}
