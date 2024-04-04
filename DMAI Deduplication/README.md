# Programming Language
R version 4.3.1

# Dependencies
pacman, dplyr, devtools, stringr  

# Installation
install.packages('pacman')  
library(pacman)  
pacman::p_load(package_name, package_name, ...)

# Input Files
- **DMAI-2021-2022-compiled-dedup.csv** -> Csv file containing combined 2021-2022 DMAI records after CrossRef Lookup  
- Scopus/Output Files/**Scopus_2021_2022_Results_20240126.csv** -> Csv file containing combined 2021-2022 records from Scopus Search API payload  
- Lens/Output Files/**Lens_2021_2022_Results_20240123.csv** -> Csv file containing combined 2021-2022 records from Lens Scholarly Works API payload  
- Academic Analytics/Output Files/**aa_fd_matches_articles_2021_2022.csv** -> Csv file containing combined 2021-2022 records from Academic Analytics
- Web of Science/Output Files/**WoS_2021_2022_Results_20240123.csv** -> Csv file containing combined 2021-2022 records from Clarivate Web of Science Starter API   
- **DMAI_deduplication.R** ->  R script containing commands for analysis

# Description
The R script performs outer joins between records from each database result file and DMAI after CrossRef Lookup. This functionality identifies records that were missed during the archival process of DMAI curation. This process was conducted twice: before and after affiliation refinement. 

# Output Files
- DMAI Deduplication/Output Files/**Scopus_notin_DMAI_20240123.csv** -> Csv file containing records in Scopus payload that were not captured by DMAI  
- DMAI Deduplication/Output Files/**Lens_notin_DMAI_20240123.csv** -> Csv file containing records in Lens payload that were not captured by DMAI  
- DMAI Deduplication/Output Files/**Academic_Analytics_notin_DMAI_20240123.csv** -> Csv file containing records from Academic Analytics that were not captured by DMAI  
- DMAI Deduplication/Output Files/**WoS_notin_DMAI_20240123.csv** -> Csv file containing record from Web of Science payload that were not captured by DMAI  
- DMAI Deduplication/Output Files/**Scopus_Lens_AA_WoS_notin_DMAI_20240123.csv** -> Csv file containing all records that were not captured by DMAI deduplicated by DOI/Title

# Results
Total records from DMAI 2021-2022 = **2952** records  

The following table displays the results of database record extraction after filtering and DMAI deduplication:  
| Database  | Previous Results (2021/2022) | Previous DMAI Deduplication) | Refined Results (2021/2022) | DMAI Deduplication |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| Academic Analytics  | 8921 (4607/4317)  | 5206  | 8921 (4607/4317)  | 8673  |
| Lens  | 17296 (9330/8283)  | 15401  | 4592 (2113/3673)  | 4592  |
| Scopus  | 9218 (4753/4525)  | 3293  | 8359 (4252/4107)  | 6829  |
| Web of Science  | 3569 (1784/1785)  | 2884  | 3018 (1506/1512)  | 2352 |
| **Total**  | **39004**  | **22910**  | **20553**  | **14927**  |  
