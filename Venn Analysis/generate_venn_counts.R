# Install and load necessary packages
install.packages("pacman")
pacman::p_load(dplyr, stringr)

### IMPORT DATA ### -----------------------------------------------------------
# Datasets prior to DMAI deduplication
DMAI_dat <- read.csv("DMAI-2021-2022-compiled-dedup.csv", encoding = "UTF-8")
scopus_dat <- read.csv("Scopus/Output Files/Scopus_2021_2022_Results_20240126.csv")
lens_dat <- read.csv("Lens/Output Files/Lens_2021_2022_Results_20240123.csv")
aa_dat <- read.csv("Academic Analytics/Output Files/aa_fd_matches_articles_2021_2022.csv")
wos_dat <- read.csv("Web of Science/Output Files/WoS_2021_2022_Results_20240123.csv")

# Datasets after DMAI deduplication
scopus_DMAI_dedup <- read.csv("DMAI Deduplication/Output Files/Scopus_notin_DMAI_20240123.csv")
lens_DMAI_dedup <- read.csv("DMAI Deduplication/Output Files/Lens_notin_DMAI_20240123.csv")
aa_DMAI_dedup <- read.csv("DMAI Deduplication/Output Files/Academic_Analytics_notin_DMAI_20240123.csv")
wos_DMAI_dedup <- read.csv("DMAI Deduplication/Output Files/WoS_notin_DMAI_20240123.csv")
OAP_dat <- read.csv("OAP Deduplication/OAP_Collection_Export_Processed.csv", na.strings=c("","NA"))

### INNER JOINS CALC ### -------------------------------------------------------------
# Performs inner join on DOI/Title to count duplicated records between datasets
calc_common_records <- function(affil1_dat, affil1_DOI_col, affil1_title_col, affil2_dat, affil2_DOI_col, affil2_title_col){
  
  # Select rows from affil1_dat and affil2_dat where DOI = NA
  affil1_NA_DOI <- subset(affil1_dat, is.na(affil1_dat[[affil1_DOI_col]]))
  affil2_NA_DOI <- subset(affil2_dat, is.na(affil2_dat[[affil2_DOI_col]]))
  
  # Select rows from affil1_dat and affil2_dat where DOI != NA
  affil1_non_NA_DOI <- subset(affil1_dat, !(is.na(affil1_dat[[affil1_DOI_col]])))
  affil2_non_NA_DOI <- subset(affil2_dat, !(is.na(affil2_dat[[affil2_DOI_col]])))

  # Performs inner join on DOI when DOI != NA
  join_doi <- intersect(affil1_non_NA_DOI[[affil1_DOI_col]], affil2_non_NA_DOI[[affil2_DOI_col]])

  # Skips title lowercase when comparing with DMAI dataset
  if ((identical(affil1_dat, DMAI_dat)) | (identical(affil2_dat, DMAI_dat))) {
    # Performs inner join on Title where DOI = NA
    join_title <- intersect(affil1_NA_DOI[[affil1_title_col]], affil2_NA_DOI[[affil2_title_col]])
    
    # Returns the number of records from inner join on DOI/Title
    return(length(join_doi) + length(join_title))
  } else {
    
  # Convert title columns to lowercase
  affil1_NA_DOI[[affil1_title_col]] <- tolower(affil1_NA_DOI[[affil1_title_col]])
  affil2_NA_DOI[[affil2_title_col]] <- tolower(affil2_NA_DOI[[affil2_title_col]])
  
  # Performs inner join on Title where DOI = NA
  join_title <- intersect(affil1_NA_DOI[[affil1_title_col]], affil2_NA_DOI[[affil2_title_col]])

  # Returns the number of records from inner join on DOI/Title
  return(length(join_doi) + length(join_title))
  }
}

### INNER JOIN COUNT MATRICES ### --------------------------------------------------------------------

# List of affiliations - allows for variable name extraction with names()
# Data prior to DMAI Deduplication
DMAI_lst <- list(scopus_dat = scopus_dat, lens_dat = lens_dat, wos_dat = wos_dat, aa_dat = aa_dat, DMAI_dat = DMAI_dat)
# Data after DMAI Deduplication
OAP_lst <- list(scopus_DMAI_dedup = scopus_DMAI_dedup, lens_DMAI_dedup = lens_DMAI_dedup, 
                wos_DMAI_dedup = wos_DMAI_dedup, aa_DMAI_dedup = aa_DMAI_dedup, OAP_dat = OAP_dat)

# List of DOI/Title column names for affiliations
affil_cols <- list(
  "Scopus" = c("DOI", "Title"), 
  "Lens" = c("DOI", "Title"), 
  "WoS" = c("DOI", "Title"), 
  "AA" = c("DOI", "Title")
)


# Fill matrix with the results of inner join On Title/DOI between each affil
fill_affil_matrix <- function(affils_lst, affils_cols, DMAI_bool){
  
  # Add elements to affils_lst/cols if for DMAI or OAP iterations
  if (DMAI_bool == TRUE){
    affil_cols$DMAI <- c("doi", "title")
  } else{
    affil_cols$OAP <- c("dc.identifier.doi", "dc.title")
  }
  
  # Initialize 5*5 matrix of 0s
  affil_mat <- matrix(rep(0, length(affils_lst)*length(affils_lst)), nrow = length(affils_lst), ncol = length(affils_lst))
  
  # Iterates row, col of affil_mat, filling each position with count of inner join records
  for (i in 1:nrow(affil_mat)){
    for(j in 1:ncol(affil_mat)){
      # Extract DOI/Title column names at position i,j in affil_cols
      affil_i_cols <- affil_cols[[i]]
      affil_j_cols <- affil_cols[[j]]
      
      # Calculate inner join for affiliations at position i,j 
      affil_inner_join <- calc_common_records(affils_lst[i][[names(affils_lst)[i]]], affil_i_cols[1], affil_i_cols[2], 
                                              affils_lst[j][[names(affils_lst)[j]]], affil_j_cols[1], affil_j_cols[2])
      # Update matrix with affil_inner_join 
      affil_mat[i,j] = affil_inner_join
    }
  }
  # Add row and column names to matrix
  colnames(affil_mat) <- names(affil_cols)
  rownames(affil_mat) <- names(affil_cols)
  
  return(affil_mat)
}

# Retrieve inner join counts prior to DMAI deduplication
DMAI_mat <- fill_affil_matrix(DMAI_lst, affil_cols, TRUE)

# Retrieve inner join counts after DMAI deduplication and prior to OAP deduplication
OAP_mat <- fill_affil_matrix(OAP_lst, affil_cols, FALSE)

### EXPORT DATA ### -------------------------------------------------------------------
# Export count matrices as csv files
write.csv(DMAI_mat, "Venn Analysis/Output Count Files/Venn_Counts_Before_DMAI_Dedup.csv", row.names=TRUE)
write.csv(OAP_mat, "Venn Analysis/Output Count Files/Venn_Counts_Before_OAP_Dedup.csv", row.names=TRUE)
