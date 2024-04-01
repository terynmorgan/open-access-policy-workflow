# Programming Language
R version 4.3.1

# Dependencies
pacman, dplyr, stringr, ggvenn, venn, ggplot2, ggpolypath

# Installation
install.packages('pacman')  
library(pacman)  
pacman::p_load(package_name, package_name, ...)

# Input Files
- DMAI-2021-2022-compiled-dedup.csv -> Csv file containing combined 2021-2022 DMAI records after CrossRef Lookup
- Scopus/Output Files/Scopus_2021_2022_Results_20240126.csv -> Csv file containing combined 2021-2022 records from Scopus Search API payload
- Lens/Output Files/Lens_2021_2022_Results_20240123.csv -> Csv file containing combined 2021-2022 records from Lens Scholarly Works API payload
- Academic Analytics/Output Files/aa_fd_matches_articles_2021_2022.csv -> Csv file containing combined 2021-2022 records from Academic Analytics
- Web of Science/Output Files/WoS_2021_2022_Results_20240123.csv -> Csv file containing combined 2021-2022 records from Clarivate Web of Science Starter API

- OAP Deduplication/OAP_Collection_Export_Processed.csv -> Csv file containing processed records from OAPcollectionMetadataExport-TRIMMED-20240126.csv
- DMAI Deduplication/Output Files/Scopus_notin_DMAI_20240123.csv -> Csv file containing records in Scopus payload that were not captured by DMAI
- DMAI Deduplication/Output Files/Lens_notin_DMAI_20240123.csv -> Csv file containing records in Lens payload that were not captured by DMAI
- DMAI Deduplication/Output Files/Academic_Analytics_notin_DMAI_20240123.csv -> Csv file containing records from Academic Analytics that were not captured by DMAI
- DMAI Deduplication/Output Files/WoS_notin_DMAI_20240123.csv -> Csv file containing record from Web of Science payload that were not captured by DMAI

- DMAI_venn_diagram_analysis.R -> R script containing commands for venn diagram generation
- generate_venn_counts.R -> R script containing command for analysis

# Description
The DMAI_venn_diagram_analysis.R script generates 4 and 5-set venn diagrams to display the number of records shared between each database and DMAI records.
The generate_venn_counts.R script performs inner joins using DOI/Title to count duplicated records between databases and DMAI or OAP collection records. This functionality shows the number of records shared between each as a tabular representation of the venn diagram visualizations. 

# Output Files
- Venn Analysis/DMAI_results/Affiliation_DOI_Venn_Diagram.png -> Png file displaying a 4-set venn diagram showing the number of shared records between databases using DOI before DMAI deduplication
- Venn Analysis/DMAI_results/Affiliation_Title_Venn_Diagram.png -> Png file displaying a 4-set venn diagram showing the number of shared records between databases using Title before DMAI deduplication
- Venn Analysis/DMAI_results/DMAI_Affiliation_DOI_Venn_Diagram.png -> Png file displaying a 5-set venn diagram showing the number of shared records between databases and DMAI records using DOI before DMAI deduplication
- Venn Analysis/DMAI_results/DMAI_Affiliation_Title_Venn_Diagram.png -> Png file displaying a 5-set venn diagram showing the number of shared records between databases and DMAI records using Title before DMAI deduplication

- Venn Analysis/Output Count Files/Venn_Counts_Before_DMAI_Dedup.csv -> Csv file containing the inner join table between each database records and DMAI before deduplication.
- Venn Analysis/Output Count Files/Venn_Counts_Before_OAP_Dedup.csv -> Csv file containing the inner join table between each database records and OAP collections before deduplication.


# Results
The following table displays the number of records shared between each database and DMAI records prior to deduplication:
|   | Scopus | Lens | Web of Science | Academic Analytics | DMAI |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| Scopus | 8359 |  |  |  |  | 
| Lens | 2998 | 5786 |  |  |  | 
| Web of Science | 2660 | 1097 | 3018 |  |  | 
| Academic Analytics | 1341 | 267 | 528 | 8921 |  | 
| DMAI | 1563 | 1231 | 686 | 260 | 2949 |  

The following table displays the number of records shared between each database and OAP collection records prior to deduplication:
|   | Scopus | Lens | Web of Science | Academic Analytics | OAP |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| Scopus | 6829 |  |  |  |  | 
| Lens | 2203 | 4592 |  |  |  | 
| Web of Science | 2045 | 738 | 2352 |  |  | 
| Academic Analytics | 1152 | 193 | 453 | 8673 |  | 
| OAP | 2974 | 317 | 633 | 2764 | 21939 |  