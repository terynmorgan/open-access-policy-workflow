# Install and load necessary packages
install.packages("pacman")
pacman::p_load(dplyr)

### IMPORT DATA ### -----------------------------------------------------------
OAP_dat <- read.csv("OAP Deduplication/OAP Collection Exports/OAPcollectionMetadataExport-TRIMMED-20240126.csv")

### MERGE OAP COLUMNS ### ----------------------------------------------------------

# Combine columns with the same data into one
# dc.date.issued
OAP_dat$dc.contributor.author <- paste(OAP_dat$dc.contributor.author, OAP_dat$dc.contributor.author.., sep = "")

# dc.date_available
OAP_dat$dc.date.available <- paste(OAP_dat$dc.date.available, OAP_dat$dc.date.available.., sep = "")

# dc.date.issued
OAP_dat$dc.date.issued <- paste(OAP_dat$dc.date.issued, OAP_dat$dc.date.issued.., sep = "")

# dc.identifier.citation
OAP_dat$dc.identifier.citation <- paste(OAP_dat$dc.identifier.citation, OAP_dat$dc.identifier.citation.., 
                                        OAP_dat$dc.identifier.citation.en_US., sep = "")

# dc.identifier.doi
OAP_dat$dc.identifier.doi <- paste(OAP_dat$dc.identifier.doi, OAP_dat$dc.identifier.doi.., OAP_dat$dc.identifier, sep = "")

# dc.identifier.uri
OAP_dat$dc.identifier.uri <- paste(OAP_dat$dc.identifier.uri, OAP_dat$dc.identifier.uri.., sep = "")

# dc.relation.isversionof
OAP_dat$dc.relation.isversionof <- paste(OAP_dat$dc.relation.isversionof, OAP_dat$dc.relation.isversionof.., 
                                         OAP_dat$dc.relation.isversionof.en_US., sep = "")

# dc.relation.journal
OAP_dat$dc.relation.journal <-  paste(OAP_dat$dc.relation.journal, OAP_dat$dc.relation.journal.., 
                                      OAP_dat$dc.relation.journal.en_US, sep = "")

# dc.source
OAP_dat$dc.source <- paste(OAP_dat$dc.source, OAP_dat$dc.source.., OAP_dat$dc.relation.journal.en_US., sep = "")

# dc.title
OAP_dat$dc.title <- paste(OAP_dat$dc.title, OAP_dat$dc.title.en_US., sep = "")


### COLUMN SELECTION ### ---------------------------------------------------------------
# Select wanted columns
OAP_dat <- OAP_dat %>% select(1, 2, 4, 6, 9, 12, 14, 16, 19, 22, 25)

### EXPORT DATA ### --------------------------------------------------------------------
#write.csv(OAP_dat, "OAP Deduplication/OAP_Collection_Export_Processed.csv", row.names = FALSE)
