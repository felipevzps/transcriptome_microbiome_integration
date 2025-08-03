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

    // Run merge process
    mergeOtuTables(ch_day_file, ch_night_file)

    // Run correlationMerged
//    correlationMerged(mergeOtuTables.out.merged_otu_file, ch_expr, ch_output_dir)

    // Run correlationscsparcc
//    correlationscsparcc(mergeOtuTables.out.merged_otu_file, ch_expr, ch_output_dir)
}

