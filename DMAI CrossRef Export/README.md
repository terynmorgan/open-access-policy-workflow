# Programming Language
R version 4.3.1

# Dependencies
pacman, dplyr, plyr, readr, purrr

# Installation
install.packages("pacman")  
library(pacman)  
pacman::p_load(package_name, package_name, ...)

# Input Directories
DMAI CrossRef Export/DMAI 2021 After CrossRef Lookup -> Directory that contains 27 csv files  
DMAI CrossRef Export/DMAI 2022 After CrossRef Lookup -> Directory that contains 21 csv files  
DMAI CrossRef Export/compile_DMAI_files.R -> R script containing commands for analysis  

# Description
The R script compiles all the records from each directory into a singular file and checks for duplicate records. 

# Output Files
DMAI CrossRef Export/DMAI CrossRef Export-dedup.csv -> Csv file containing deduplicated record from 'DMAI 2021 After CrossRef Lookup' directory
DMAI CrossRef Export/DMAI-2022-compiled-dedup.csv -> Csv file containing deduplicated record from 'DMAI 2022 After CrossRef Lookup' directory
DMAI-2021-2022-compiled-dedup.csv -> Csv file combining 2021 and 2022 DMAI records after CrossRef Lookup

# Results
Total records for DMAI 2021/2022 = 2952
