
### IMPORT DATA ### -------------------------------------------------------
aa_affil_matches <- read.csv("Academic Analytics/aa_fd_matches_articles_2023-11-21_8-57-29.csv") # N = 87046

### PREPROCESS DATA ### ----------------------------------------------------

# Preprocess aa_affil_matches for 2021/2022
preprocess_aa_affil <- function(aa_affil_df, aa_year){
  # Filter by year
  if (length(aa_year) > 1) aa_affil <- subset(aa_affil_df, year %in% aa_year)
  else aa_affil <- subset(aa_affil_df, year == aa_year)
  
  # Extract columns
  aa_affil <- subset(aa_affil, select = c(articlematchid, articletitle, journalname, year, doi))
  
  # Rename columns
  names(aa_affil) <- c("Match.ID", "Title", "Journal.Name", "Pub.Year", "DOI")
  
  # Deduplicate on DOI
  aa_affil_dedup <-  aa_affil[!duplicated(aa_affil$DOI),]
  # Deduplicate on Title
  aa_affil_dedup <-  aa_affil_dedup[!duplicated(aa_affil_dedup$Title),]
  
  return(aa_affil_dedup)
}


# Preprocess for 2021, 2022, and 2021/2022
aa_affil_2021 <- preprocess_aa_affil(aa_affil_matches, 2021) # N = 4607
aa_affil_2022 <- preprocess_aa_affil(aa_affil_matches, 2022) # N = 4317
aa_affil_2021_2022 <- preprocess_aa_affil(aa_affil_matches, c(2021,2022)) # N = 8921


### EXPORT DATA ### ------------------------------------------------------
#write.csv(aa_affil_2021, "Academic Analytics/Output Files/aa_fd_matches_articles_2021.csv", row.names = FALSE)
#write.csv(aa_affil_2022, "Academic Analytics/Output Files/aa_fd_matches_articles_2022.csv", row.names = FALSE)
#write.csv(aa_affil_2021_2022, "Academic Analytics/Output Files/aa_fd_matches_articles_2021_2022.csv", row.names = FALSE)
