# Install necessary packages
install.packages("pacman")
pacman::p_load(httr, jsonlite, xml2, dplyr, XML)


### WOS GET REQUEST ### --------------------------------------------------------
# API token
token <- "3f6d429da82de0cfffc8362045d998f74689a3cf"

# Creates GET request using token and query
get_wos_data <- function(token, query_params){
  url <- "https://api.clarivate.com/apis/wos-starter/v1/documents"
  headers <- c("X-ApiKey" = token, "Content-Type" = "application/json")
  httr::GET(url = url, add_headers(.headers=headers), query = query_params)
}


### SEARCH TERMS ### ----------------------------------------------------------
# Affiliations to include/exclude
affils <- c("Indiana University-Purdue University Indianapolis", "Richard L. Roudebush VA Medical Center", 
            "Regenstrief Institute Inc", "Indiana University Bloomington")

# Document Types to include/exclude
doc_types <- c("Data Paper", "Article", "Letter", "Proceedings Paper", "Review", "Early Access", "Book", "Book Chapter")

# Publication year range
pub_years <- c(2021, 2022)


### WOS QUERY ### -------------------------------------------------------------------
# Boolean affiliation query 
affils_include <- paste("((OG=(", paste(head(affils, -1), sep = "", collapse =" OR "), "))", sep="")
# Exclude Bloomington
affils_exclude <- paste(" NOT OG=(", tail(affils, 1), "))", sep="")

# Boolean document query
# Include Data paper, Article, Letter, Proceedings paper, and review
doc_types_include <- paste(" AND DT=(", paste(head(doc_types, -3), sep="", collapse=" OR "), "))", sep="")
# Exclude Early Access, Book, and Book Chapters
doc_types_exclude <- paste(" NOT DT=(", paste(tail(doc_types, 3), sep="", collapse=" OR "), ")", sep="")

# Boolean query for publication year (2021 or 2022)
pub_years_include <- paste(" AND PY=(", paste(pub_years, sep="", collapse=" OR "), "))", sep="")

# Create query using affiliations, document types, and publication years
wos_query <- paste("((", affils_include, affils_exclude, doc_types_include, doc_types_exclude, pub_years_include, sep="")

# Query parameters 
# sort pub year (PY) in ascending order
query_params <- list(
  q = wos_query,
  db = "WOS", 
  limit = 50, 
  page = 1, 
  sortField = "PY+A"
)


### SCROLL PAGINATION ### ---------------------------------------------------------------

# Max returned results = 50, need cursor based pagination
scroll_pagination <- function(token, query_params){
  
  # GET request and extract text response
  response <- get_wos_data(token, query_params)
  #response <- GET(url = url, query = query_params, add_headers(headers))
  record_json <- httr::content(response, "text", encoding = "UTF-8")
  
  # Convert json > list > df
  record_list <- jsonlite::fromJSON(record_json)
  record_df <- data.frame(record_list)
  
  # Total results
  total_results <- record_list$metadata$total # 3865
  max_results <- record_list$metadata$limit
  
  if(total_results > max_results){
    # Calculate the number of queries needed
    sets <- ceiling(total_results/max_results)
    
    # Loop through sets of results needed to bring back all records into a df
    for (i in 2:sets){
      
      # New query based on page number
      new_query_params <- list(
        q = wos_query,
        db = "WOS", 
        limit = 50, 
        page = i, 
        sortField = "PY+A"
      )
      
      # GET request with new page number and extract text results
      response <- get_wos_data(token, new_query_params)
      record_json <- httr::content(response, "text", encoding = "UTF-8")
      
      # Convert json > list > df
      record_list <- jsonlite::fromJSON(record_json)
      new_df <- data.frame(record_list)
      
      # Bind latest query df to previous df
      record_df <- dplyr::bind_rows(record_df, new_df)
    }
  }
  return(record_df)
}

# GET request results for 2021/2
wos_results <- scroll_pagination(token, query_params) # 3258


### PREPROCESS RESULTS ### ------------------------------------------------------------------------
# Extract title, types, source, and identifier columns
response_df_filtered <- subset(wos_results, select = c(hits.title, hits.types, hits.source, hits.identifiers))

# Index pubyear, source title, and doi from hits.source and hits.identifiers
response_df_filtered$hits.pubyear <- response_df_filtered$hits.source[2] # pub year
response_df_filtered$hits.source <- response_df_filtered$hits.source[1] # journal name
response_df_filtered$hits.identifiers <- response_df_filtered$hits.identifiers[1] # doi


### DEDUPLICATION ### -----------------------------------------------------------------------
# Deduplicate records on DOI - remove NA and dedup
response_df_non_NA <- subset(response_df_filtered, !(is.na(hits.identifiers))) # N = 3184
response_df_non_NA <- response_df_filtered[!duplicated(response_df_filtered$hits.identifiers),] # N = 3181
# Add DOI NA records back in 
wos_dedup <- dplyr::bind_rows(response_df_non_NA, subset(response_df_filtered, is.na(hits.identifiers))) # N = 3255
                              
# Deduplicate records on Title 
wos_dedup <- wos_dedup[!duplicated(wos_dedup$hits.title),] # N = 3251
# Rename and reorder columns
names(wos_dedup) <- c("Title", "Doc.Type", "Journal.Name", "DOI", "Pub.Year")
wos_dedup <- wos_dedup[,c(1, 3, 5, 4, 2)]


### SEPARATE 2021/2 ### -------------------------------------------------------------------
# Subset to get 2021 and 2022 - remove 2020 and 2023
wos_dedup_2021_2022 <- subset(wos_dedup, Pub.Year == 2021 | Pub.Year == 2022) # N = 3018

# Subset 2021 and 2022 pubyears
wos_dedup_2021 <- subset(wos_dedup_2021_2022, Pub.Year == 2021) # N = 1506
wos_dedup_2022 <- subset(wos_dedup_2021_2022, Pub.Year == 2022) # N = 1512

# Unlist the dataframes to export
wos_dedup_2021_2022 <- apply(wos_dedup_2021_2022, 2, as.character) # 2021/22 records
wos_dedup_2021 <- apply(wos_dedup_2021, 2, as.character) # 2021 records
wos_dedup_2022 <- apply(wos_dedup_2022, 2, as.character) # 2022 records


### EXPORT WOS RESULTS ### ----------------------------------------------------------------
write.csv(wos_dedup_2021_2022, "Web of Science/Output Files/WoS_2021_2022_Results_20240123.csv", row.names = FALSE)
write.csv(wos_dedup_2021, "Web of Science/Output Files/WoS_2021_Results_20240123.csv", row.names = FALSE)
write.csv(wos_dedup_2022, "Web of Science/Output Files/WoS_2022_Results_20240123.csv", row.names = FALSE)
