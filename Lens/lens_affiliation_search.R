# Install and load necessary packages
install.packages("pacman")
pacman::p_load(httr, jsonlite, dplyr, rlist, XML)

### LENS POST REQUEST  ### -----------------------------------------------------------
# API token
LENS_API_TOKEN <- "4dMG7Wr8YPpOSNOr8FFFjCPxxyNuwqmS2iaYRR71tYyjiL2JZeGI"
# Maximum number of records returned per query
max_results <- 1000

# Creates POST request using token and query
get_scholary_data <- function(token, query){
  url <- "https://api.lens.org/scholarly/search"
  headers <- c('Authorization' = token, 'Content-Type' = 'application/json')
  httr::POST(url = url, add_headers(.headers=headers), body = query)
}

### LENS QUERY ### -------------------------------------------------------------------

# Function to separate 2021/2022 in POST
lens_query <- function(year_start, year_end){
  request <- paste0('{
    "query":{
      "bool":{
        "must":[
          {"bool":{
            "should":[
              {"match_phrase":{"author.affiliation.ror_id": "05gxnyn08"}},
              {"match_phrase":{"author.affiliation.ror_id": "046z54t28"}},
              {"match_phrase":{"author.affiliation.ror_id": "05rbkcx47"}},
              {"match_phrase":{"author.affiliation.ror_id": "00n9fkm63"}},
              {"match_phrase":{"author.affiliation.ror_id": "02fj1x097"}},
              {"match_phrase":{"author.affiliation.ror_id": "02seeba69"}},
              {"match_phrase":{"author.affiliation.name": "Indiana University School of Medicine and Regenstrief Institute, Inc, Center for Aging Research"}},
              {"match_phrase":{"author.affiliation.name": "Indiana University School of Medicine"}},
              {"match_phrase":{"author.affiliation.name": "Indiana University School of Medicine Indianapolis IN USA"}},
              {"match_phrase":{"author.affiliation.name": "School of Medicine, Indiana University School of Medicine"}},
              {"match_phrase":{"author.affiliation.name": "Indiana University Center for Bioethics"}},
              {"match_phrase":{"author.affiliation.name": "Robert H McKinney School of Law"}},
              {"match_phrase":{"author.affiliation.name": "Indiana University School of Dentistry"}},
              {"match_phrase":{"author.affiliation.name": "IU School of Nursing"}},
              {"match_phrase":{"author.affiliation.name": "Indiana University School of Nursing"}},
              {"match_phrase":{"author.affiliation.name": "Richard M. Fairbanks School of Public Health"}},
              {"match_phrase":{"author.affiliation.name": "IU Richard M. Fairbanks School of Public Health at IUPUI"}}
            ]
          }},
          {"bool":{
            "should":[
              {"term":{"publication_type": "journal article"}},
              {"term":{"publication_type": "conference proceedings article"}},
              {"term":{"publication_type": "conference proceedings"}},
              {"term":{"publication_type": "letter"}},
              {"term":{"publication_supplementary_type": "review"}}
            ]
          }}
        ],
        "filter": {
          "range": {
            "year_published": {
              "gte": "',year_start,'",
              "lte": "',year_end,'"
            }
          }
        }
      }
    },
    "include":["title", "external_ids", "source.title", "year_published", "publication_type", "is_open_access", "open_access.colour"],
    "size": "',max_results,'",
    "scroll": "1m"
  }')
  return(request)
}


### SCROLL PAGINATION ### ----------------------------------------------------

# Since max returned results = 1000, need Cursor Based Pagination
scroll_pagination <- function(token, query){
  
  # POST request and extract text results
  data <- get_scholary_data(token, query)
  record_json <- httr::content(data, "text")
  
  # Convert json > list > df
  record_list <- jsonlite::fromJSON(record_json)
  record_df <- data.frame(record_list)
  
  # Total results
  total <- record_list[["total"]]
  
  # CURSOR BASED PAGINATION
  if (total > max_results){
    # Calculate the number of queries needed 
    sets <- ceiling(total/max_results) 
    
    # Extract scroll ID from query to go back to the same search
    scroll_id <- record_list[["scroll_id"]]
    
    # Loop through sets of results needed to bring back all records into a df
    for (i in 2:sets){
      # Extract latest scroll_id from last query
      scroll_id <- record_list[["scroll_id"]]
      
      # New query based on scroll_id and including "include" for efficiency
      request <- paste0('{"scroll_id": "', 
                        scroll_id,
                        '", "include": ["title", "external_ids", "source.title", "year_published", "publication_type", "is_open_access", "open_access.colour"]
                      }')
      
      # POST request with new scroll_id and extract text results
      data <- get_scholary_data(token, request)
      record_json <- httr::content(data, "text")
      
      # Convert json > list > df
      record_list <- jsonlite::fromJSON(record_json) 
      new_df <- data.frame(record_list)
      
      # Bind latest search df to previous df
      record_df <- dplyr::bind_rows(record_df, new_df)
    }
  }
  return(record_df)
}

# POST request results for 2021-2022 (ranged)
lens_result_2021_2022 <- scroll_pagination(LENS_API_TOKEN, lens_query(2021, 2022)) # N = 5852

### PREPROCESS LENS RESULTS ### ---------------------------------------------------------

# Preprocess external_ids column from Lens POST results
preprocess_lens_result <- function(record_df){
  
  # Extract DOI from external_ids column
  record_df$DOI <- lapply(record_df$data.external_ids, function(external_ids) {
    
    # Subset external_ids for DOI in type 
    result <- subset(external_ids, type == "doi")
    
    # If DOI doesn't exist, add NA to column
    if (nrow(result) == 0) res <- NA
    else res <- result$value
    
    return(res)
  })
  
  # Drop columns
  record_df <- subset(record_df, select=-c(total, max_score, scroll_id, data.external_ids, results))
  # Replace NA in open access flag to FALSE
  record_df$data.is_open_access[is.na(record_df$data.is_open_access)] <- FALSE
  
  # Cast df to str (gets rid of list in DOI)
  record_df <- apply(record_df, 2, as.character)
  
  # Replace str "NA" with NA
  record_df[record_df == "NA"] <- NA
  
  # Returns df of compiled records
  return(record_df)
}


# Preprocess lens 2021/2 results
lens_2021_2022_processed <- data.frame(preprocess_lens_result(lens_result_2021_2022))
# Rename and reorder columns
names(lens_2021_2022_processed) <- c("Title", "Doc.Type", "Pub.Year", "OA.Color", "Journal.Name", "OA.Flag", "DOI")
lens_2021_2022_processed <- lens_2021_2022_processed[,c(1, 5, 3, 7, 2, 6, 4)]

### DEDUPLICATION ### -----------------------------------------------------------------------
# Deduplicate lens results on DOI/Title
deduplicate_lens <- function(lens_processed_df, DOI_col, Title_col){
  
  # Extract records where lens_processed_df DOI = NA
  lens_NA_DOI <- subset(lens_processed_df, is.na(DOI_col))
  # Extract records where lens_processed_df DOI != NA
  lens_non_NA_DOI <- subset(lens_processed_df, !(is.na(DOI_col)))
  
  # Remove duplicate records on DOI
  lens_non_NA_DOI <- lens_non_NA_DOI[!duplicated(lens_non_NA_DOI$DOI_col),]
  
  # Add NA records back in 
  lens_dedup <- rbind(lens_non_NA_DOI, subset(lens_processed_df, is.na(DOI_col)))
  
  # Remove duplicate titles
  lens_dedup <- lens_dedup[!duplicated(lens_dedup$Title_col),] 
  
  # Return dedup df
  return(lens_dedup)
}


# Remove duplicate DOI/Title for 2021/2 results
lens_2021_2022_dedup <- deduplicate_lens(lens_2021_2022_processed, lens_2021_2022_processed[["DOI"]], lens_2021_2022_processed[["Title"]])

# Separate into lens results into 2021/2
lens_2021_dedup <- subset(lens_2021_2022_dedup, Pub.Year == "2021") # N = 2113
lens_2022_dedup <- subset(lens_2021_2022_dedup, Pub.Year == "2022") # N = 3673

### EXPORT DATA ### ------------------------------------------------------------------------
write.csv(lens_2021_dedup, "Lens/Output Files/Lens_2021_Results_20240123.csv", row.names = FALSE)
write.csv(lens_2022_dedup, "Lens/Output Files/Lens_2022_Results_20240123.csv", row.names = FALSE)
write.csv(lens_2021_2022_dedup, "Lens/Output Files/Lens_2021_2022_Results_20240123.csv", row.names = FALSE)

