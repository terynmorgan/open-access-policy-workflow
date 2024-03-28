# Programming Language
R version 4.3.1

# Dependencies
pacman, httr, jsonlite, xml2, dplyr, XML 
Clarivate Web of Science Starter API Token: 
- https://developer.clarivate.com/apis/wos-starter
- https://developer.clarivate.com/#getStarted
- https://developer.clarivate.com/applications?page=1

# Installation
install.packages('pacman')  
library(pacman)  
pacman::p_load(package_name, package_name, ...)

# Input Files
Web of Science/wos_affiliation_search.R -> R script containing commands for analysis 

# Description
The R script queries the Web of Science Starter API for articles affiliated with IUPUI. Results were filtered for works within 2021-2022 and deduplicated on DOI/Title.

## Affiliation Refinement
**Affiliations:**  IUPUI, Richard L Roudebush VA Medical Center, Regenstrief Institute Inc, Indiana University System, Walther Cancer Institute, Eskenazi Health  

**Refined Affiliations:**  IUPUI, Richard L Roudebush VA Medical Center, Regenstrief Institute Inc, Indiana University System 

# Output Files
Web of Science/Output Files/WoS_2021_2022_Results_20240123.csv -> Csv file containing deduplicated records from the 2021 Clarivate payload
Web of Science/Output Files/WoS_2021_Results_20240123.csv -> Csv file containing deduplicated records from the 2022 Clarivate payload
Web of Science/Output Files/WoS_2022_Results_20240123.csv -> Csv file combining records from 2021/2022 results  

# Results
Total records before affiliation refinement = **3569 records**
- 2021 = 1784 records
- 2022 = 1785 records 

Total records after affiliation refinement = **3018 records**
- 2021 = 1506 records
- 2022 = 1512 records
