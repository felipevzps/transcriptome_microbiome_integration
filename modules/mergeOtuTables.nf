process mergeOtuTables {
    label "process_low"
    tag "Merging OTU tables"

    input:
        path(day_file)
        path(night_file)

    output:
        path("merged_otu_table.tsv"), emit: merged_otu_file

    script:
        """
        ${projectDir}/../bin/merge_tables.py --day ${day_file} --night ${night_file} --output merged_otu_table.tsv
        """
}
