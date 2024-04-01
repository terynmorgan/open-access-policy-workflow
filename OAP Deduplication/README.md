# Programming Language
R version 4.3.1

# Dependencies
pacman, dplyr, devtools, stringr, ggplot2, ggpolypath, ggvenn, venn

# Installation
install.packages('pacman')  
library(pacman)  
pacman::p_load(package_name, package_name, ...)

# Input Files
- OAP Deduplication/OAP Collection Exports/**OAPcollectionMetadataExport-TRIMMED-20240126.csv** -> Csv file containing records from IUPUI's Open Access Policy metadata collection from 1981-2024  
- OAP Deduplication/**preprocess_OAP.R** -> R script containing commands to preprocess the OAP collection metadata exports  
- DMAI Deduplication/Output Files/**Scopus_notin_DMAI_20240123.csv** -> Csv file containing records in Scopus payload that were not captured by DMAI  
- DMAI Deduplication/Output Files/**Lens_notin_DMAI_20240123.csv** -> Csv file containing records in Lens payload that were not captured by DMAI  
- DMAI Deduplication/Output Files/**Academic_Analytics_notin_DMAI_20240123.csv** -> Csv file containing records from Academic Analytics that were not captured by DMAI  
- DMAI Deduplication/Output Files/**WoS_notin_DMAI_20240123.csv** -> Csv file containing record from Web of Science payload that were not captured by DMAI  
- DMAI Deduplication/Output Files/**Scopus_Lens_AA_WoS_notin_DMAI_20240123.csv** -> Csv file containing all records that were not captured by DMAI deduplicated by DOI/Title  
- **OAP_deduplication.R** -> R script containing commands for OAP deduplication analysis

# Description
The preprocess_OAP.R script merges duplicate columns in OAPcollectionMetadataExport-TRIMMED-20240126.csv and selects specific columns for export.  
The OAP_deduplication.R script performs outer joins between records from each database result file after DMAI deduplication and the processed OAP records. This functionality further refines the results of the DMAI deduplication and identifies records that were not captured within the OAP collections. The R script also generates 4 and 5-set venn diagrams to display the number of records shared between each database and the OAP collections. 

# Output Files
- OAP Deduplication/Output Files/**Scopus_notin_OAP_20240202.csv** -> Csv file containing records in Scopus payload that were not captured by DMAI or OAP collections  
- OAP Deduplication/Output Files/**Lens_notin_OAP_20240202.csv** -> Csv file containing records in Lens payload that were not captured by DMAI or OAP collections  
- OAP Deduplication/Output Files/**Academic_Analytics_notin_OAP_20240202.csv** -> Csv file containing records from Academic Analytics that were not captured by DMAI or OAP collections  
- OAP Deduplication/Output Files/**WoS_notin_OAP_20240202.csv** -> Csv file containing record from Web of Science payload that were not captured by DMAI or OAP collections  
- OAP Deduplication/Output Files/**Scopus_Lens_AA_WoS_notin_OAP_20240202.csv** -> Csv file containing all records that were not captured by the OAP collections deduplicated by DOI/Title  
- Venn Analysis/OAP Results/**OAP_Affiliation_DOI_Venn_Diagram.png** -> Png file displaying a 4-set venn diagram showing the number of shared records between databases using DOI  
- Venn Analysis/OAP Results/**OAP_Affiliation_Title_Venn_Diagram.png** -> Png file displaying a 4-set venn diagram showing the number of shared records between databases using Title  
- Venn Analysis/OAP Results/**OAP_Affiliation_5set_DOI_Venn_Diagram.png** -> Png file displaying a 5-set venn diagram showing the number of shared records between databases and the OAP collections using DOI  
- Venn Analysis/OAP Results**/OAP_Affiliation_5set_Title_Venn_Diagram.png** -> Png file displaying a 5-set venn diagram showing the number of shared records between databases and the OAP collections using Title  

# Results
The following table displays the results of database record extraction after filtering and DMAI/OAP deduplication:  
| Database  | Refined Results (2021/2022) | DMAI Deduplication | OAP Deduplication |
| ------------- | ------------- | ------------- | ------------- |
| Academic Analytics  | 8921 (4607/4317)  | 8673  | 5904 |
| Lens  |  4592 (2113/3673)  | 4592  | 4575 |
| Scopus  | 8359 (4252/4107)  | 6829  | 3855 |
| Web of Science  | 3018 (1506/1512)  | 2352 | 1718 |
| **Total**  | **20553**  | **14927**  | **11137**
