# Install and load necessary packages
install.packages("pacman")
pacman::p_load(dplyr, devtools, stringr, ggplot2, ggpolypath, ggvenn, venn)

### IMPORT DATA ### -----------------------------------------------------------
scopus_DMAI_dedup <- read.csv("DMAI Deduplication/Output Files/Scopus_notin_DMAI_20240123.csv")
lens_DMAI_dedup <- read.csv("DMAI Deduplication/Output Files/Lens_notin_DMAI_20240123.csv")
aa_DMAI_dedup <- read.csv("DMAI Deduplication/Output Files/Academic_Analytics_notin_DMAI_20240123.csv")
wos_DMAI_dedup <- read.csv("DMAI Deduplication/Output Files/WoS_notin_DMAI_20240123.csv")
OAP_dat <- read.csv("OAP Deduplication/OAP_Collection_Export_Processed.csv", na.strings=c("","NA"))

# OAP DEDUPLICATION ### ---------------------------------------------------------

# Performs outer join between DOI/Title of affiliation and OAP records
OAP_deduplication <- function(OAP_dat, OAP_DOI_col, OAP_title_col, affil_dat, affil_DOI_col, affil_title_col){
  
  # Convert title columns to lowercase
  OAP_dat[[OAP_title_col]] <- tolower(OAP_dat[[OAP_title_col]])
  affil_dat[[affil_title_col]] <- tolower(affil_dat[[affil_title_col]])

  # Select rows from affil_dat and OAP_dat where DOI = NA
  OAP_NA_DOI <- subset(OAP_dat, is.na(OAP_dat[[OAP_DOI_col]]))
  affil_NA_DOI <- subset(affil_dat, is.na(affil_dat[[affil_DOI_col]]))
  
  # Select rows from affil_dat and OAP_dat where DOI != NA
  OAP_non_NA_DOI <- subset(OAP_dat, !(is.na(OAP_dat[[OAP_DOI_col]])))
  affil_non_NA_DOI <- subset(affil_dat, !(is.na(affil_dat[[affil_DOI_col]])))
  # Check and remove duplicate DOIs
  affil_non_NA_DOI <- affil_non_NA_DOI[!duplicated(affil_non_NA_DOI[[affil_DOI_col]]),] 
  
  # When DOI != NA, inner join made on DOI
  join_doi <- intersect(OAP_non_NA_DOI[[OAP_DOI_col]], affil_non_NA_DOI[[affil_DOI_col]]) 
  # Extract records not in join_doi => outer join on DOI
  affil_res_doi <- subset(affil_non_NA_DOI, !(affil_non_NA_DOI[[affil_DOI_col]] %in% join_doi)) 
  
  # Combine affil_res_doi with records where DOI = NA
  affil_res <- rbind(affil_res_doi, affil_NA_DOI)
  
  # Performs inner join on Title 
  join_title <- intersect(OAP_NA_DOI[[OAP_title_col]], affil_res[[affil_title_col]])

  # Extract records not in join_title => outer join on title
  affil_res_title <- subset(affil_res, !(affil_res[[affil_title_col]] %in% join_title))

  # Return data frame of outer join results
  return(affil_res_title)
}

## Outer join results from OAP to affiliations(Scopus, Lens, AA, and WoS)
OAP_Scopus <- OAP_deduplication(OAP_dat, "dc.identifier.doi", "dc.title",  scopus_DMAI_dedup, "DOI",  "Title") # N = 3855
OAP_Lens <- OAP_deduplication(OAP_dat, "dc.identifier.doi", "dc.title",  lens_DMAI_dedup, "DOI", "Title") # n = 4575
OAP_AA <- OAP_deduplication(OAP_dat, "dc.identifier.doi", "dc.title", aa_DMAI_dedup, "DOI", "Title") # N = 5904
OAP_WoS <- OAP_deduplication(OAP_dat, "dc.identifier.doi", "dc.title",  wos_DMAI_dedup, "DOI", "Title") # N = 1718

### COMBINE AND PROCESS RESULTS ### ----------------------------------------------------------------
Scopus_Lens_AA_WoS_res <- do.call("rbind", list(OAP_Lens, OAP_AA, OAP_AA, OAP_Scopus)) # N = 19938

# Deduplicate on DOI
Scopus_Lens_AA_WoS_non_NA <- subset(Scopus_Lens_AA_WoS_res, !is.na(DOI)) # N = 19797
Scopus_Lens_AA_WoS_non_NA <- Scopus_Lens_AA_WoS_non_NA[!duplicated(Scopus_Lens_AA_WoS_non_NA$DOI),] # N = 12075
Scopus_Lens_AA_WoS_dedup <- dplyr::bind_rows(Scopus_Lens_AA_WoS_non_NA, subset(Scopus_Lens_AA_WoS_res, is.na(DOI))) # N = 12216

# Exact match deduplication on Title
Scopus_Lens_AA_WoS_dedup <- Scopus_Lens_AA_WoS_dedup[!duplicated(Scopus_Lens_AA_WoS_dedup$Title),] # N = 11137

# Convert all titles back to title case then export results
Scopus_Lens_AA_WoS_dedup$Title <- str_to_title(Scopus_Lens_AA_WoS_dedup$Title) # N = 11137

### EXPORT DEDUP RESULTS ### -------------------------------------------------------------------------------

#Export files from Scopus, Lens, AA outer join with OAP
write.csv(OAP_Scopus, "OAP Deduplication/20240202 Results/Scopus_notin_OAP_20240202.csv", row.names = FALSE)
write.csv(OAP_Lens, "OAP Deduplication/20240202 Results/Lens_notin_OAP_20240202.csv", row.names = FALSE)
write.csv(OAP_AA, "OAP Deduplication/20240202 Results/Academic_Analytics_notin_OAP_20240202.csv", row.names = FALSE)
write.csv(OAP_WoS, "OAP Deduplication/20240202 Results/WoS_notin_OAP_20240202.csv", row.names = FALSE)

# Export combination results
write.csv(Scopus_Lens_AA_WoS_dedup, "OAP Deduplication/20240202 Results/Scopus_Lens_AA_WoS_notin_OAP_20240202.csv", row.names = FALSE)

### CREATE DOI/TITLE LISTS ### -----------------------------------------------------------------------
# Title list for venn comparison
comb_title <- list(
  OAP = lower(OAP_dat$dc.title),
  Scopus = lower(scopus_DMAI_dedup$Title), 
  Lens = lower(lens_DMAI_dedup$Title), 
  AA = lower(aa_DMAI_dedup$Title),
  WoS = lower(wos_DMAI_dedup$Title)
)

# DOI list where DOI != NA for venn comparison 
comb_DOI <- list(
  OAP = subset(OAP_dat, !is.na(dc.identifier.doi))$dc.identifier.doi,
  Scopus = subset(scopus_DMAI_dedup, !is.na(DOI))$DOI,
  Lens = subset(lens_DMAI_dedup, !is.na(DOI))$DOI,
  AA = subset(aa_DMAI_dedup, !is.na(DOI))$DOI,
  WoS = subset(wos_DMAI_dedup, !is.na(DOI))$DOI
)


### 4-SET VENN ANALYSIS ### --------------------------------------------------------------------------------

# Venn Diagram between affiliation DOIs where DOI != NA
png("Venn Analysis/OAP Results/OAP_Affiliation_DOI_Venn_Diagram.png")
venn_plot <- ggvenn(
  comb_DOI[2:length(comb_DOI)], 
  fill_color = c("#0073C2FF", "#EFC000FF", "#868686FF", "#CD534CFF"),
  stroke_size = 0.5, set_name_size = 4
)
venn_plot <- venn_plot + 
  labs(title ="OAP Deduplication Affiliation DOI Venn Diagram",
       subtitle = "Plot of DOI when DOI is not missing") + 
  theme(plot.title = element_text(face="bold", hjust = 0.5), 
        plot.subtitle = element_text(face = "italic", hjust = 0.5))
print(venn_plot)
dev.off()


# Venn Diagram between affiliation Titles without filtration
png("Venn Analysis/OAP Results/OAP_Affiliation_Title_Venn_Diagram.png")
venn_plot <- ggvenn(
  comb_title[2:length(comb_title)], 
  fill_color = c("#0073C2FF", "#EFC000FF", "#868686FF", "#CD534CFF"),
  stroke_size = 0.5, set_name_size = 4
)
venn_plot <- venn_plot + labs(title = "OAP Deduplication Affiliation Title Venn Diagram") + theme(plot.title = element_text(face="bold", hjust = 0.5))
print(venn_plot)
dev.off()


### 5-SET VENN ANALYSIS ### --------------------------------------------------------------------------------
# Venn Diagram between affiliation and OAP DOIs where DOI != NA
png("Venn Analysis/OAP Results/OAP_Affiliation_5set_DOI_Venn_Diagram.png")
venn_plot <- venn(
  comb_DOI, 
  ilabels = "counts", 
  zcolor = "#911eb4, #F2CA19, #e6194B, #0057E9, #3cb44b", 
  ggplot = TRUE
)
venn_plot <- venn_plot + 
  labs(title ="OAP Deduplication Affiliation DOI Venn Diagram",
       subtitle = "Plot of DOI when DOI is not missing") + 
  theme(plot.title = element_text(face="bold", hjust = 0.5, size = 16, margin = margin(b = 2)), 
        plot.subtitle = element_text(face = "italic", hjust = 0.5, size = 12, margin = margin(b = -15))) 
print(venn_plot)
dev.off()


# Venn Diagram between affiliation and OAP Titles
png("Venn Analysis/OAP Results/OAP_Affiliation_5set_Title_Venn_Diagram.png")
venn_plot <- venn(
  comb_title, 
  ilabels = "counts", 
  zcolor = "#911eb4, #F2CA19, #e6194B, #0057E9, #3cb44b", 
  ggplot = TRUE
)
venn_plot <- venn_plot +
  labs(title = "OAP Deduplication Affiliation Title Venn Diagram") + 
  theme(plot.title = element_text(face="bold", hjust = 0.5, size = 16, margin = margin(b = -15)))
print(venn_plot)
dev.off()  
