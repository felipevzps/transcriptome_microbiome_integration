#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Include modules
include { mergeOtuTables }        from './modules/mergeOtuTables.nf'
include { correlationMerged }     from './modules/correlationMerged.nf'
include { correlationscsparcc }   from './modules/correlationscsparcc.nf'

workflow {

    // Define channels for each input
    Channel.fromPath(params.day_file)    .set { ch_day_file }
    Channel.fromPath(params.night_file)  .set { ch_night_file }
    Channel.value(params.output_dir)     .set { ch_output_dir }
    Channel.fromPath(params.expression_matrix) .set { ch_expr }

    //WORKFLOW START

    //run process mergeOtuTables
    ch_day_file, ch_night_file = ch_output_dir | mergeOtuTables
    mergeOtuTables.out.view{ "mergeOtuTables: $it"}

    //run process CorrelationMerged
    merged_otu.merged_otu_file, ch_expr = ch_output_dir | correlationMerged
    correlationMerged.out.view{ "correlationMerged: $it"}

    //run process Correlationscsparcc
    merged_otu.merged_otu_file, ch_expr = ch_output_dir | correlationscsparcc
    correlationscsparcc.out.view{ "correlationscsparcc: $it"}
}
