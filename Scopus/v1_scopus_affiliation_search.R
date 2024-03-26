# Install and load necessary packages
install.packages("pacman")
pacman::p_load(httr, xml2, dplyr, readxl, XML)

### SCOPUS GET REQUEST ### -------------------------------------------------------------
# API token
token <- "2522b9aceb92e5bf7d3c08de1bb91ea3" 

get_scopus_data <- function(token, url){
  headers <- c(Accept = "application/xml", `X-ELS-APIKey` = token)
  httr::GET(url, add_headers(headers))
}

### AFFILIATION IDS ### -----------------------------------------------------------------
# Read in excel file of affiliation IDs
all_af_ids <- read_excel("Scopus/Scopus_Affiliation_IDs.xlsx", col_names=TRUE)

# Extract IDs affiliated with IU - 36 IDs -> 9 w/ filtration
af_ids <- all_af_ids[all_af_ids$Keep == "Yes",]$Scopus_Affiliation_ID 

# Create URL encoded boolean affiliation query to be used in GET request 
# URL encoded - af-id(60032114) +OR+ af-id(60022265) -> af-id(60032114)%20%2BOR%2B%20af-id(60022265)
affil_id_query <-  paste("(", paste("af-id(",af_ids,")", sep = "", collapse = "%20%2BOR%2B%20"), ")", sep="") 


### DOCUMENT TYPES ### -----------------------------------------------------------------
# Article, Review, Note, Letter, Conference Paper, Data paper
doc_types <- c("ar", "re", "le", "cp", "dp")

# Create URL encoded boolean document type query
# DOCTYPE(ar) +OR+ DOCTYPE(re) -> (DOCTYPE(ar)%20%2BOR%2B%20DOCTYPE(re)
doc_type_query <- paste("(", paste("DOCTYPE(",doc_types,")", sep="", collapse = "%20%2BOR%2B%20"), ")", sep="")


### TIME RANGE ### ---------------------------------------------------------------------
## Create two URL encoded ranges of publication dates (2021, 2022)
pub_date_2021 <- "PUBYEAR%20%3D%202021" # PUBYEAR = 2021
pub_date_2022 <- "PUBYEAR%20%3D%202022" # PUBYEAR = 2022

### CREATE URL QUERY ### --------------------------------------------------------------------
# Scopus url
url <-  "http://api.elsevier.com/content/search/scopus?query="

# Compiled affiliation IDs, document types, and date for query parameters separated by +AND+
scopus_query_2021 <- paste(affil_id_query, doc_type_query, pub_date_2021, sep="%20%2BAND%2B%20") # 2021
scopus_query_2022 <- paste(affil_id_query, doc_type_query, pub_date_2022, sep="%20%2BAND%2B%20") # 2022

# Creates urls for GET request 
  # Uses STANDARD payload response (&view - max 25 results), returning title, doi, OA flag, and journal name (&field)
  # Sorts response by coverDate then title in ascending order (&sort) 
scopus_url_2021 <- paste(url, scopus_query_2021, "&view=STANDARD", "&sort=coverDate,+title", "&field=title,doi,openaccess,publicationName,subtype,coverDate", sep="") # 2021 
scopus_url_2022 <- paste(url, scopus_query_2022, "&view=STANDARD", "&sort=coverDate,+title", "&field=title,doi,openaccess,publicationName,subtype,coverDate", sep="") # 2022


### SCROLL PAGINATION W/ START ### ------------------------------------------------------------------------

# Max returned results with each request &view=STANDARD is 25, so need cursor based pagination
scroll_pagination <- function(token, url){
  
  # GET request and parse XML results
  response <- get_scopus_data(token, url)
  res_xml <- xmlParse(response)
  
  # Total results
  total_results <-  as.numeric(xpathSApply(res_xml, "//opensearch:totalResults", xmlValue)) # 2021 = 4375, 2022 = 4175
  max_results <- 25
  
  if (total_results > max_results){
    # Iterators for ?start= in url query (by 25)
    start_iter <- seq(0, total_results, max_results)
    
    # Empty lists to hold scopus data
    titles_vect <- c()
    pub_names_vect <- c()
    pub_years_vect <- c()
    dois_vect <- c()
    doc_types_vect <- c()
    OA_flags_vect <- c()
    
    # Loop through sets of results to bring back all records
    for (iter in start_iter){
      # Add &start iter to url
      new_url <- paste(url, "&start=", iter, sep="")
      
      # GET request with new ?start and parse XML results
      response <- get_scopus_data(token, new_url)
      res_xml <- xmlParse(response)
      
      # Extract title node set using Xpath query 
      titles <- sapply(getNodeSet(res_xml, "//dc:title"), xmlValue)
      
      # Extract journal names
      pub_names <- sapply(getNodeSet(res_xml, "//prism:publicationName"), xmlValue)
      
      # Extract coverDate node set
      pub_date_nodes <- getNodeSet(res_xml, "//prism:coverDate")
      # Extract year from coverDate values
      pub_years <- substr(sapply(pub_date_nodes, xmlValue), 1, 4)
      
      # Extract prism:doi as sibling of prism:coverDate
      dois <- sapply(pub_date_nodes, function(x) xmlValue(getSibling(x)))
      
      # Extract document type node set and values
      doc_types <- sapply(pub_date_nodes, function(x) xmlValue(getSibling(getSibling(x))))
      
      # Extract openaccessFlags as 3rd sibling of prism:coverDate
      OA_flags <- sapply(pub_date_nodes, function(x)  xmlValue(getSibling(getSibling(getSibling(x)))))
      
      # Add title/pub_names/doi/openaccess to respective vectors
      titles_vect <- append(titles_vect, titles)
      pub_names_vect <- append(pub_names_vect, pub_names)
      pub_years_vect <- append(pub_years_vect, pub_years)
      dois_vect <- append(dois_vect, dois)
      doc_types_vect <- append(doc_types_vect, doc_types)
      OA_flags_vect <- append(OA_flags_vect, OA_flags)
    }
  }
  return(list(titles_vect, pub_names_vect, pub_years_vect, dois_vect, doc_types_vect, OA_flags_vect))
}

# Returns list of title, pub_name, pub_year, doi, OA status, and doc_types for 2021/2
scopus_res_2021_list <- scroll_pagination(token, scopus_url_2021)
scopus_res_2022_list <- scroll_pagination(token, scopus_url_2022)


### PREPROCESS SCOPUS RESULTS ### ------------------------------------------------------------------

# 2021 Results - list -> df
scopus_2021_df <- data.frame(Title = scopus_res_2021_list[1], Journal.Name = scopus_res_2021_list[2], 
                             Pub.Year = scopus_res_2021_list[3], DOI = scopus_res_2021_list[4],
                             Doc.Type = scopus_res_2021_list[5], OA_Flag = scopus_res_2021_list[6]) #  N = 4375
names(scopus_2021_df) <- c("Title", "Journal.Name", "Pub.Year", "DOI", "Doc.Type", "OA.Flag") # Add cols

# 2022 Results - list -> df
scopus_2022_df <- data.frame(Title = scopus_res_2022_list[1], Journal.Name = scopus_res_2022_list[2], 
                             Pub.Year = scopus_res_2022_list[3], DOI = scopus_res_2022_list[4],
                             Doc.Type = scopus_res_2022_list[5], OA_Flag = scopus_res_2022_list[6]) # N = 4175
names(scopus_2022_df) <- c("Title", "Journal.Name", "Pub.Year", "DOI", "Doc.Type", "OA.Flag") # Add cols

# Combine 2021/22 dataframes
scopus_comb_df <- rbind(scopus_2021_df, scopus_2022_df) # N = 8550


### DEDUPLICATION ### -----------------------------------------------------------------------

# Remove NA and deduplicate on DOI
scopus_non_NA <- subset(scopus_comb_df, !(is.na(DOI))) # N = 8488
scopus_non_NA <- scopus_non_NA[!duplicated(scopus_non_NA$DOI),] # N = 8395
# Add NA records back in 
scopus_res_dedup <- rbind(scopus_non_NA, subset(scopus_comb_df, is.na(DOI))) # N = 8395

# Deduplicate on Title
scopus_dedup <- scopus_res_dedup[!duplicated(scopus_res_dedup$Title),] # N = 8359

# Separate into 2021/22
scopus_dedup_2021 <- subset(scopus_dedup, Pub.Year == 2021) # N = 4252
scopus_dedup_2022 <- subset(scopus_dedup, Pub.Year == 2022) # N = 4107
