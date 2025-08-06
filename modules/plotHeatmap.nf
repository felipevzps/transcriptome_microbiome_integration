process plotHeatmap {
    label "process_low"
    tag "heatmap"

    input:
        path(correlation_matrix)

    output:
        path("correlation_heatmap.png"), emit: correlation_heatmap_file

    script:
        """
        ${projectDir}/../bin/plot_heatmap.py --corr ${correlation_matrix} --output correlation_heatmap.png
        """
}
