# Transcriptome-Microbiome Integration
[![Nextflow](https://img.shields.io/badge/workflow-nextflow-blue)](https://www.nextflow.io/) [![Status](https://img.shields.io/badge/status-active-success.svg)]() [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)  

This Nextflow pipeline automates the integration of transcriptomic expression profiles and microbiome abundance data (OTU tables), performing cross-correlation analysis to uncover potential associations between host transcriptome-microbiome associations.

---
# prerequisites

This pipeline requires Nextflow 25.04.2 or higher.  
>Follow [this tutorial](https://www.nextflow.io/docs/latest/install.html) to install Nextflow.

We use Conda to avoid dependency conflicts and ensure reproducible environments across different systems.  
Make sure you have installed Conda 25.5.1 or higher.
>Follow [this tutorial](https://www.anaconda.com/docs/getting-started/miniconda/install#linux) to install Miniconda, a miniature version of Anaconda.

---

# installing

Clone this repository:

```bash
git clone https://github.com/SantosRAC/transcriptome_microbiome_integration.git
cd transcriptome_microbiome_integration
```

---

# input files

This pipeline requires an input sample containing the following information:    
- Expression Matrix: A TSV file containing RNA expression from the transcriptome 
- OTU Table: A TSV file containing the OTU information of the microbiome 

See an example of input files [here](https://github.com/SantosRAC/transcriptome_microbiome_integration/tree/main/samples).

--- 

# configuring

After installing, make sure to update the configuration file with your input file paths.  

See an example below:

```
head -n13 config/nextflow.config

params {
  // $publishDir relative paths
  out_dir         = "../results"
  report_dir      = "report"
  environment_dir = "../envs"
  conda_cache_dir = "conda-cache"

  // path to samples
  day_file          = "$projectDir/../samples/filtered_otu_table_day_filtered_rel_abund_cv_filtered.tsv"
  night_file        = "$projectDir/../samples/filtered_otu_table_night_filtered_rel_abund_cv_filtered.tsv"
  expression_matrix = "$projectDir/../samples/expression_matrix.tsv"
```

>[!TIP]
>This is the [configuration file](https://github.com/SantosRAC/transcriptome_microbiome_integration/blob/main/config/nextflow.config) used in this study.


# running the pipeline

From the pipeline root directory, execute:

```bash
cd transcriptome_microbiome_integration

# example for running the pipeline locally  
nextflow run workflows/main.nf -c config/nextflow.config -profile local

# you can use the -resume flag to re-run the pipeline if some step failed
nextflow run workflows/main.nf -c config/nextflow.config -resume -profile local
```

---

# questions?

For suggestions, bug reports, or collaboration, feel free to open an [issue](https://github.com/SantosRAC/transcriptome_microbiome_integration/issues).
