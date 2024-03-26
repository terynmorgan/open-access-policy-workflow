# Install necessary packages
install.packages("pacman")
pacman::p_load(dplyr, plyr, readr, purrr)

### COMPILE FILES FROM DMAI FOLDERS ### ----------------------------------------
# Get paths for each folder
DMAI_2021_path <- "DMAI CrossRef Export/DMAI 2021 After CrossRef Lookup"
DMAI_2022_path <- "DMAI CrossRef Export/DMAI 2022 After CrossRef Lookup"

# Combine all files from DMAI file path into a data frame
compiled_DMAI_files <- function(file_path){
  DMAI_files <- list.files(file_path, full.names = TRUE) %>%   # Gets all csvs from folder path 
    lapply(read_csv, col_types = cols(.default = "c")) %>%     # Stores files in a list
    bind_rows()                                                # Combines all files row-wise
  
  DMAI_files_df <- as.data.frame(DMAI_files)                   # Convert tibble into dataframe
  DMAI_files_df
}


# Data frames for DMAI 2021/2022
DMAI_2021_files_df <- compiled_DMAI_files(DMAI_2021_path) # N = 3594
DMAI_2022_files_df <- compiled_DMAI_files(DMAI_2022_path) # N = 2372

# Check for duplicate records
DMAI_2021_files_dedup <- DMAI_2021_files_df[!(duplicated(DMAI_2021_files_df$title)),] # N = 1797
DMAI_2022_files_dedup <- DMAI_2022_files_df[!(duplicated(DMAI_2022_files_df$title)),] # N = 1155

# Combine 2021 and 2022 into one data frame
DMAI_2021_2022_files <- rbind(DMAI_2021_files_dedup, DMAI_2022_files_dedup) # N = 2952
# Check for duplicates
DMAI_2021_2022_dedup <- DMAI_2021_2022_files[!(duplicated(DMAI_2021_2022_files$title)),] # N = 2952

# Export Files
write.csv(DMAI_2021_files_dedup, file='DMAI CrossRef Export/DMAI 2021 After CrossRef Lookup/DMAI-2021-compiled-dedup.csv', row.names=FALSE)
write.csv(DMAI_2022_files_dedup, file='DMAI CrossRef Export/DMAI 2022 After CrossRef Lookup/DMAI-2022-compiled-dedup.csv', row.names=FALSE)
write.csv(DMAI_2021_2022_dedup, file='DMAI-2021-2022-compiled-dedup.csv', row.names=FALSE)
