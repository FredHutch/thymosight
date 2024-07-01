# ThymoSight

ThymoSight is an R Shiny app we have developed to allow interactive exploration of all mouse and human publicly available single cell datasets of the non-hematopoietic thymic stroma. ThymoSight provides dataset metadata fields (if available/applicable): tissue, age, stage, sorted cell population, gender, genotype, treatment, linked publication and mapped annotation based on our own subset signatures and original annotation. This repository includes both the app.R code that launches the app together with the Jupyter notebooks used to create consistent annotation fields, reanalyze and integrate the public datasets with ours. The server hosting the interactive app can be accessed at www.thymosight.org.

## ThymoSight input data

The ThymoSight app input data have been created from publicly available datasets and our own submitted data. Accession numbers for all datasets used to create these input files are provided here.

### Public mouse data
- Kernfeld et al. (2018)<sup>1</sup> [GSE107910]
- Bornstein et al. (2018)<sup>1</sup> [GSE103967]
- Dhalla et al. (2019)<sup>3</sup> [https://www.ebi.ac.uk/biostudies/arrayexpress/studies/E-MTAB-8105#]
- Baran-Gale et al. (2020)<sup>4</sup> [https://bioconductor.org/packages/release/data/experiment/html/MouseThymusAgeing.html]
- Wells et al. (2020)<sup>5</sup> [GSE137699]
- Rota et al. (2021)<sup>6</sup> [GSE162668]
- Nusser et al. (2022)<sup>7</sup> [GSE106856]
- Michelson et al. (2022)<sup>8</sup> [GSE194253]
- Klein et al. (2023)<sup>9</sup> [GSE215418]
- Farley et al. (2023)<sup>10</sup> [GSE232765]
- Givony et al. (2023)<sup>11</sup> [GSE236075]
- Michelson et al. (2023)<sup>12</sup> [GSE225661]
- Horie et al. (2023)<sup>13</sup> [GSE228198]
- Kousa et al. (2024) [GSE240020]

### Public human data
- Park et al. (2020)<sup>14</sup> [https://zenodo.org/records/3711134]
- Bautista et al. (2021)<sup>15</sup> [GSE147520]
- Ragazzini et al. (2023)<sup>16</sup> [GSE220830, GSE220206, GSE220829]  

<br>

> The re-analyzed public datasets with added metadata that are used as input for this app can be accessed at [10.5281/zenodo.12516405](https://zenodo.org/records/12516405).
<br>

## Citations
<sup>1</sup>Kernfeld, E. M. et al. A Single-Cell Transcriptomic Atlas of Thymus Organogenesis Resolves Cell Types and Developmental Maturation. Immunity (2018). https://doi.org/10.1016/j.immuni.2018.04.015  
<sup>2</sup>Bornstein, C. et al. Single-cell mapping of the thymic stroma identifies IL-25-producing tuft epithelial cells. Nature 559, 622-626 (2018). https://doi.org/10.1038/s41586-018-0346-1  
<sup>3</sup>Dhalla, F. et al. Biologically indeterminate yet ordered promiscuous gene expression in single medullary thymic epithelial cells. Embo j, e101828 (2019). https://doi.org/10.15252/embj.201910182  
<sup>4</sup>Baran-Gale, J. et al. Ageing compromises mouse thymus function and remodels epithelial cell differentiation. Elife 9 (2020). https://doi.org/10.7554/eLife.56221  
<sup>5</sup>Wells, K. L. et al. Combined transient ablation and single-cell RNA-sequencing reveals the development of medullary thymic epithelial cells. eLife 9, e60188 (2020). https://doi.org/10.7554/eLife.60188  
<sup>6</sup>Rota, I. A. et al. FOXN1 forms higher-order nuclear condensates displaced by mutations causing immunodeficiency. Sci Adv 7, eabj9247 (2021). https://doi.org/10.1126/sciadv.abj9247  
<sup>7</sup>Nusser, A. et al. Developmental dynamics of two bipotent thymic epithelial progenitor types. Nature 606, 165-171 (2022). https://doi.org/10.1038/s41586-022-04752-8  
<sup>8</sup>Michelson, D. A., Hase, K., Kaisho, T., Benoist, C. & Mathis, D. Thymic epithelial cells co-opt lineage-defining transcription factors to eliminate autoreactive T cells. Cell 185, 2542-2558 e2518 (2022). https://doi.org/10.1016/j.cell.2022.05.018  
<sup>9</sup>Klein, F. et al. Combined multidimensional single-cell protein and RNA profiling dissects the cellular and functional heterogeneity of thymic epithelial cells. bioRxiv, 2022.2009.2014.507949 (2022). https://doi.org/10.1101/2022.09.14.507949. 
<sup>10</sup>Farley, A. M. et al. Thymic epithelial cell fate and potency in early organogenesis assessed by single cell transcriptional and functional analysis. Front Immunol 14, 1202163 (2023). https://doi.org/10.3389/fimmu.2023.1202163  
<sup>11</sup>Givony, T. et al. Thymic mimetic cells function beyond self-tolerance. Nature (2023). https://doi.org/10.1038/s41586-023-06512-8  
<sup>12</sup>Michelson, D. A., Zuo, C., Verzi, M., Benoist, C. & Mathis, D. Hnf4 activates mimetic-cell enhancers to recapitulate gut and liver development within the thymus. Journal of Experimental Medicine 220 (2023). https://doi.org/10.1084/jem.20230461  
<sup>13</sup>Horie, K. et al. Acute irradiation causes a long-term disturbance in the heterogeneity and gene expression profile of medullary thymic epithelial cells. Front Immunol 14, 1186154 (2023). https://doi.org/10.3389/fimmu.2023.1186154  
<sup>14</sup>Park, J. E. et al. A cell atlas of human thymic development defines T cell repertoire formation. Science 367, eaay3224 (2020). https://doi.org/10.1126/science.aay3224  
<sup>15</sup>Bautista, J. L. et al. Single-cell transcriptional profiling of human thymic stroma uncovers novel cellular heterogeneity in the thymic medulla. Nature Communications 12, 1096 (2021). https://doi.org/10.1038/s41467-021-21346-6. 
<sup>16</sup>Ragazzini, R. et al. Defining the identity and the niches of epithelial stem cells with highly pleiotropic multilineage potency in the human thymus. Developmental cell (2023). https://doi.org/10.1016/j.devcel.2023.08.017  
