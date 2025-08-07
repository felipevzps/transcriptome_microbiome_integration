process correlationMerged {
    label "process_low"
    tag "correlate"

    input:
        path(otu_table)
        path(expression_matrix)

    output:
        path("otu_gene_correlation.tsv"), emit: otu_gene_correlation_file

    script:
        """
        ${projectDir}/../bin/scipy_pearson_correlation.py --otu ${otu_table} --expr ${expression_matrix} --output otu_gene_correlation.tsv
        """
}
