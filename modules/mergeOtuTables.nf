#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process mergeOtuTables {
    tag "Merging OTU tables"

    input:
    //tuple path(day_file)
    path day_file
    path night_file

    output:
    path("merged_otu_table.tsv"), emit: merged_otu_file

    script:
   """
    ${projectDir}/../bin/merge_tables.py $day_file $night_file
   """
}


