# Programming Language
R version 4.3.1

# Dependencies
pacman, httr, xml2, dplyr, readxl, XML  
Scopus Search API Token: https://dev.elsevier.com/
- Documentation: https://dev.elsevier.com/documentation/SCOPUSSearchAPI.wadl

# Installation
install.packages('pacman')  
library(pacman)  
pacman::p_load(package_name, package_name, ...)

# Input Files
Scopus/Scopus_Affiliation_IDs.xlsx -> Excel file containing affiliations associated with IUPUI  
Scopus/v2_scopus_affiliation_search.R -> Second iteration of an R script containing commands for analysis  
Scopus/v1_scopus_affiliation_search.R -> First iteration of an R script containing commands for analysis 

# Description
The R scripts query the Scopus Search API for articles affiliated with IUPUI and filter the returned works withhin 2021-2022 and deduplicated on DOI/Title. The second iteration of the R script implements cursor-based scroll pagination for a more streamlined execution.  
**Fields in Response:** Title, Journal Name, Publication Year, DOI, Document Type, OA Flag (T/F)

## Affiliation Refinement
To refine the affiliations kept in the search query, affiliations in Scopus/Scopus_Affiliation_IDs.xlsx where Keep = Yes were included. 
- *IUPUI, IUPUC, IU School of Medicine, IU Robert H. McKinney School of Law, IU School of Dentistry, IU School of Nursing, Regenstrief Institute, Richard L. Roudebush VAMC*

# Output Files
Scopus/Output Files/Scopus_2021_Results_20240126.csv -> Csv file containing deduplicated records from the 2021 Scopus payload
Scopus/Output Files/Scopus_2022_Results_20240126.csv -> Csv file containing deduplicated records from the 2022 Scopus payload
Scopus/Output Files/Scopus_2021_2022_Results_20240126.csv -> Csv file combining records from 2021/2022 results  

# Results
Total records before affiliation refinement = **9013** records
- 2021 = **4661** records
- 2022 = **4449** records

Total records after affiliation refinement = **4022** records
- 2021 = **2014** records
- 2022 = **2016** records
