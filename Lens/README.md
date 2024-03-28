# Programming Language
R version 4.3.1

# Dependencies
pacman, httr, jsonlite, dplyr, rlist, XML  
Lens Scholarly Works API Token: https://www.lens.org/lens/user/subscriptions

# Installation
install.packages('pacman')  
library(pacman)  
pacman::p_load(package_name, package_name, ...)

# Input Files
Lens/lens_affiliation_search -> R script containing commands for analysis 

# Description
The R script queries the Lens Scholary Works API for articles affiliated with IUPUI. ROR IDs were used for the affiliation search when available. For affiliations without a ROR ID, the Lens UI was used to variations of affiliaton names and those were used in an exact match in the query. Results were filtered for works within 2021-2022 and deduplicated on DOI/Title.

## Affiliation Refinement
To refine the affiliations kept in the search query, affiliations in Lens/lens_ror_ids.xlsx where Keep? = Yes were included. 

# Output Files
Lens/Output Files/Lens_2021_Results_20240123.csv -> Csv file containing deduplicated records from the 2021 Lens payload
Lens/Output Files/Lens_2022_Results_20240123.csv-> Csv file containing deduplicated records from the 2022 Lens payload
Lens/Output Files/Lens_2021_2022_Results_20240123.csv -> Csv file combining records from 2021/2022 results  

# Results
Total records before affiliation refinement = 17296 records
- 2021 = 9330 records
- 2022 = 8283 records 

Total records after affiliation refinement = 5786 records
- 2021 = 2113 records
- 2022 = 3673 records