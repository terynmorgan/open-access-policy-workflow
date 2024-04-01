# Install and load necessary packages
install.packages("pacman")
pacman::p_load(dplyr, devtools, stringr)

### IMPORT DATA ### -----------------------------------------------------------
DMAI_dat <- read.csv("DMAI-2021-2022-compiled-dedup.csv")
scopus_dat <- read.csv("Scopus/Output Files/Scopus_2021_2022_Results_20240126.csv")
lens_dat <- read.csv("Lens/Output Files/Lens_2021_2022_Results_20240123.csv")
aa_affil_dat <- read.csv("Academic Analytics/Output Files/aa_fd_matches_articles_2021_2022.csv")
wos_dat <- read.csv("Web of Science/Output Files/WoS_2021_2022_Results_20240123.csv")

### SEPARATE DATA BASED ON DOI ### --------------------------------------------
# Separate each df by records where DOI = NA
separate_NA <- function(affil_dat, doi_col){

  # Select frows from affil_dat where DOI = NA
  affil_NA_DOI <- subset(affil_dat, is.na(doi_col))
  # affil_dat DOI != NA
  affil_non_NA_DOI <- subset(affil_dat, !(is.na(doi_col)))
  
  # Remove duplicate rows based on DOI
  affil_non_NA_DOI <- affil_non_NA_DOI[!duplicated(doi_col),]
  
  # Returns list of dataframes: DOI = NA, DOI != NA
  return(list(affil_NA_DOI, affil_non_NA_DOI))
}

# Create list of 2 dataframes: where DOI = NA and DOI != NA
DMAI_sep_list <- separate_NA(DMAI_dat, DMAI_dat[["doi"]]) # N = (98, 2852)
scopus_sep_list <- separate_NA(scopus_dat, scopus_dat[["DOI"]]) # N = (0, 8359)
lens_sep_list <- separate_NA(lens_dat, lens_dat[["DOI"]]) # N = (168, 5619)
aa_affil_sep_list <- separate_NA(aa_affil_dat, aa_affil_dat[["DOI"]]) # N = (0, 8921)
wos_sep_list <- separate_NA(wos_dat, wos_dat[["DOI"]] ) # N = (73,2946)

### DMAI JOINS ### ------------------------------------------------------------
# Function to perform outer join with DMAI and given affiliation records
two_field_join <- function(DMAI_dat_list, affil_dat_list, DMAI_DOI_col, affil_DOI_col, DMAI_title_col, affil_title_col){
  
  # When the affiliation doesn't have any NA DOIs, join only on DOI
  if (missing(DMAI_title_col) & missing(affil_title_col)){
    # DOI != NA, join made on DOI
    join_doi <- intersect(DMAI_dat_list[[2]][[DMAI_DOI_col]], affil_dat_list[[2]][[affil_DOI_col]])
    print(length(join_doi))
    # Extract outer join (affil not in DMAI) on DOI
    affil_res_doi <- subset(affil_dat_list[[2]], !(affil_dat_list[[2]][[affil_DOI_col]] %in% join_doi))
    
    # Return dataframes of outer join on DOI
    return(affil_res_doi)
    
  } else {
    
    # DOI = NA, join made on title
    # Have to use [[col_name]] instead of $ to pass col_name in 
    join_title <- intersect(DMAI_dat_list[[1]][[DMAI_title_col]], affil_dat_list[[1]][[affil_title_col]])
    # Extract outer join on title
    affil_res_title <- subset(affil_dat_list[[1]], !(affil_dat_list[[1]][[affil_title_col]] %in% join_title))
    print(length(join_title))
    
    # DOI != NA, join made on DOI
    join_doi <- intersect(DMAI_dat_list[[2]][[DMAI_DOI_col]], affil_dat_list[[2]][[affil_DOI_col]])
    # Extract outer join (affil not in DMAI) on DOI
    affil_res_doi <- subset(affil_dat_list[[2]], !(affil_dat_list[[2]][[affil_DOI_col]] %in% join_doi))
    print(length(join_doi))
    
    affil_res <- rbind(affil_res_title, affil_res_doi)
    # Return dataframe of outer join on DOI and Title
    #return(affil_res)
    return(length(join_doi) + length(join_title))
  }
}

# Outer join results from Scopus, Lens, AA, and WoS
# DMAI list, affil list, DMAI doi, affil doi, DMAI title, affil title
DMAI_Scopus <- two_field_join(DMAI_sep_list, scopus_sep_list, "doi", "DOI") # N = 6829
DMAI_Lens <- two_field_join(DMAI_sep_list, lens_sep_list, "doi", "DOI", "title", "Title") # N = 4592
DMAI_AA <- two_field_join(DMAI_sep_list, aa_affil_sep_list, "doi", "DOI") # N = 8673
DMAI_WoS <- two_field_join(DMAI_sep_list, wos_sep_list, "doi", "DOI", "title", "Title") # N = 2352

### PREPROCESS RESULTS ### ------------------------------------------------------
# To combine affils into one result, need same column names/number of columns
cols <- c("Title", "Journal.Name", "Pub.Year", "DOI", "OA.Flag")

# Scopus preprocess
# Drop Doc.Type column
DMAI_Scopus <- DMAI_Scopus[,c(1,2,3,4,6)]

# Lens preprocess
# Drop OA.Color columns
DMAI_Lens <- DMAI_Lens[,c(1,2,3,4,6)]
# Cast OA.Flag to character
DMAI_Lens$OA.Flag <- as.character(DMAI_Lens$OA.Flag)

# AA preprocess
# Add a column of NA for OA flag
DMAI_AA$OA.Flag <- "NA"
# Drop articlematchid
DMAI_AA <- select(DMAI_AA, -1)

# WoS preprocess
# Add a column of NA for OA flag
DMAI_WoS$OA.Flag <- "NA"
# Drop Doc.Type column
DMAI_WoS <- DMAI_WoS[,c(1,2,3,4,6)]

### COMBINE RESULTS ### --------------------------------------------------------------
# Combine Scopus, Lens, AA, and WoS results
Scopus_Lens_AA_WoS_res <- do.call("rbind", list(DMAI_Lens, DMAI_AA, DMAI_WoS, DMAI_Scopus)) # N = 22446

# Deduplicate on DOI
Scopus_Lens_AA_WoS_non_NA <- subset(Scopus_Lens_AA_WoS_res, !is.na(DOI)) # N = 22211
Scopus_Lens_AA_WoS_non_NA <- Scopus_Lens_AA_WoS_non_NA[!duplicated(Scopus_Lens_AA_WoS_non_NA$DOI),] # N = 16701
Scopus_Lens_AA_WoS_dedup <- dplyr::bind_rows(Scopus_Lens_AA_WoS_non_NA, subset(Scopus_Lens_AA_WoS_res, is.na(DOI))) # N = 16936

# Convert all titles to lowercase
Scopus_Lens_AA_WoS_dedup$Title <- tolower(Scopus_Lens_AA_WoS_dedup$Title)
# Exact match deduplication on Title
Scopus_Lens_AA_WoS_dedup <- Scopus_Lens_AA_WoS_dedup[!duplicated(Scopus_Lens_AA_WoS_dedup$Title),] # N = 14927

# Convert all titles back to title case then export results
Scopus_Lens_AA_WoS_dedup$Title <- str_to_title(Scopus_Lens_AA_WoS_dedup$Title)

### EXPORT RESULTS ### ----------------------------------------------------------------
#Export files from Scopus, Lens, AA outer join with DMAI
write.csv(DMAI_Scopus, "DMAI Deduplication/Output Files/Scopus_notin_DMAI_20240123.csv", row.names = FALSE)
write.csv(DMAI_Lens, "DMAI Deduplication/Output Files/Lens_notin_DMAI_20240123.csv", row.names = FALSE)
write.csv(DMAI_AA, "DMAI Deduplication/Output Files/Academic_Analytics_notin_DMAI_20240123.csv", row.names = FALSE)
write.csv(DMAI_WoS, "DMAI Deduplication/Output Files/WoS_notin_DMAI_20240123.csv", row.names = FALSE)

# Export combination results
write.csv(Scopus_Lens_AA_WoS_dedup, "DMAI Deduplication/Output Files/Scopus_Lens_AA_WoS_notin_DMAI_20240123.csv", row.names = FALSE)
