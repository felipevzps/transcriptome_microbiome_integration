#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Include modules
include { mergeOtuTables }        from '../modules/mergeOtuTables.nf'
include { correlationMerged }     from '../modules/correlationMerged.nf'
include { correlationscsparcc }   from '../modules/correlationscsparcc.nf'

workflow {

    // Input channels
    Channel.fromPath(params.day_file)    .set { ch_day_file }
    Channel.fromPath(params.night_file)  .set { ch_night_file }
    Channel.value(params.out_dir)     .set { ch_output_dir }
    Channel.fromPath(params.expression_matrix) .set { ch_expr }

    // Run merge process
    mergeOtuTables(ch_day_file, ch_night_file, ch_output_dir)

    // Run correlationMerged
    correlationMerged(mergeOtuTables.out.merged_otu_file, ch_expr, ch_output_dir)

    // Run correlationscsparcc
    correlationscsparcc(mergeOtuTables.out.merged_otu_file, ch_expr, ch_output_dir)
}

