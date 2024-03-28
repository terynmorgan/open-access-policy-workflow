# Programming Language
R version 4.3.1

# Dependencies
None

# Input Directories
Academic Analytics/aa_fd_matches_articles_2023-11-21_8-57-29.csv -> Csv file containing exports from Academic Analytics  
Academic Analytics/preprocess_academic_analytics -> R script containing commands for analysis  

# Description
The R script filters academic analytics file for records in 2021/2022 and duplicated records on Title/DOI.

# Output Files
Academic Analytics/Output Files/aa_fd_matches_articles_2021.csv -> Csv file containing deduplicated records in 2021 from input file  
Academic Analytics/Output Files/aa_fd_matches_articles_2022.csv -> Csv file containing deduplicated records in 2022 from input file  
Academic Analytics/Output Files/aa_fd_matches_articles_2021_2022.csv -> Csv file combining records from 2021/2022 results  

# Results
Total records (deduplicated on Title and DOI) = 8921 records
- 2021 = 4607 records
- 2022 = 4317 records
