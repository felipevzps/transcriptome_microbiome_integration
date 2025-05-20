#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Import the module
include { mergeOtuTables } from './modules/mergeOtuTables.nf'

workflow {

    // Validate required inputs
    if (!params.day_file || !params.night_file) {
        error "Missing required parameters: --day_file and --night_file"
    }

    // Create input channels
    day_ch   = Channel.fromPath(params.day_file)
    night_ch = Channel.fromPath(params.night_file)
    out_dir  = params.output_dir

    // Run the process
    mergeOtuTables(
        day_ch,
        night_ch,
        out_dir
    )
}
