process correlationscsparxcc {
    label "process_high"
    tag "cross_correlation_SparXCC"

    input:
        path(otu_table)
        path(expression_file)

    output:
        path("SparXCC_output_day_common_samples.txt"),   emit: sparxcc_day_correlation_matrix
        path("SparXCC_output_night_common_samples.txt"), emit: sparxcc_night_correlation_matrix

    script:
        """
        # if necessary, install CompoCor: https://github.com/IbTJensen/CompoCor
        Rscript -e "
        if (!require('CompoCor', quietly=TRUE)) {
            library(devtools)
            install_github('IbTJensen/CompoCor')
        }
        "
        
        Rscript ${projectDir}/../bin/cross_cor_SparXCC.r ${otu_table} ${expression_file}
        """
}
