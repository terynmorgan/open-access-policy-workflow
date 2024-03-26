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

# Pub date between 2021-2022
pub_dates <- c(2021, 2022)

# Create URL encoded boolean pub date query
# (PUBYEAR = 2021 +OR+ PUBYEAR = 2022) -> (PUBYEAR%20%3D%202021%20%2BOR%2B%20PUBYEAR%20%3D%202022)
pub_date_query <- paste("(", paste("PUBYEAR%20%3D%20",pub_dates, sep="", collapse = "%20%2BOR%2B%20"), ")", sep="")

### CREATE URL QUERY ### --------------------------------------------------------------------
# Scopus url
url <-  "http://api.elsevier.com/content/search/scopus?query="

# Compiled affiliation IDs, document types, and date for query parameters separated by +AND+
scopus_query <- paste(affil_id_query, doc_type_query, pub_date_query, sep="%20%2BAND%2B%20")

# Creates urls for GET request 
  # Uses STANDARD payload response (&view - max 25 results), returning title, doi, OA flag, and journal name (&field)
  # Sorts response by coverDate then title in ascending order (&sort) 
  # Adds &cursor=*&count=25 for cursor-based pagination
scopus_url <- paste(url, scopus_query, "&view=STANDARD", "&sort=coverDate,+title", "&field=title,doi,openaccess,publicationName,subtype,coverDate", "&cursor=*&count=25", sep="") 


### CURSOR-BASED SCROLL PAGINATION ### ------------------------------------------------------------------------

# From the parsed XML response, extract fields, and append to respective lists
extract_fields <- function(res_xml, titles_vect, pub_names_vect, pub_years_vect,
                           dois_vect, doc_types_vect, OA_flags_vect){
  
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
  
  # Compile lists into a dataframe
  scopus_df <- data.frame(Title = titles_vect, Journal.Name = pub_names_vect, 
                          Pub.Year = pub_years_vect, DOI = dois_vect,
                          Doc.Type = doc_types_vect, OA.Flag = OA_flags_vect)
  
  return(scopus_df)
}


# Max returned results with 5000, so need cursor-based pagination
scroll_pagination <- function(token, url){
  
  # GET request and parse XML results
  response <- get_scopus_data(token, url)
  res_xml <- xmlParse(response)
  
  # Empty lists to hold Scopus data
  titles_vect <- c()
  pub_names_vect <- c()
  pub_years_vect <- c()
  dois_vect <- c()
  doc_types_vect <- c()
  OA_flags_vect <- c()
  
  # Extract fields from first xml response in df
  res_df <- extract_fields(res_xml, titles_vect, pub_names_vect, pub_years_vect,
                 dois_vect, doc_types_vect, OA_flags_vect)
  
  # Define the namespaces (prefixes for unique element accession)
  xml_ns <- c(atom = "http://www.w3.org/2005/Atom", opensearch = "http://a9.com/-/spec/opensearch/1.1/")
  
  # Total results
  total_results <-  as.numeric(xpathSApply(res_xml, "//opensearch:totalResults", xmlValue)) # 2021 = 4252, 2022 = 4107
  max_results <- 25
  
  # Cursor-based pagination if total results > 25
  if (total_results > max_results){
    # Calculate the number of queries needed
    sets <- ceiling(total_results/max_results)
    
    # Loop through sets of results to bring back all records
    for (i in 2:sets){
      
      # Get the <link> element from the namespace where ref='next' 
      cursor_element <- getNodeSet(res_xml, "//atom:link[@ref='next']", namespaces = xml_ns)[[1]]
      
      # Extract the "href" attribute that defines a new query URL with the next cursor value
      cursor_url <- xmlGetAttr(cursor_element, "href")
      
      # GET request with new ?start and parse XML results
      response <- get_scopus_data(token, cursor_url)
      res_xml <- xmlParse(response)
      
      # Extract fields in a df from iterative GET responses
      new_df <- extract_fields(res_xml, titles_vect, pub_names_vect, pub_years_vect,
                      dois_vect, doc_types_vect, OA_flags_vect)
      
      # Bind latest search df to previous df
      res_df <- dplyr::bind_rows(res_df, new_df)
    }
  }
  # Return df of compiled fields
  return(res_df)
}


# Compile fields from 2021-2022 response 
scopus_res_df <- scroll_pagination(token, scopus_url) # N = 8488


### DEDUPLICATION ### -----------------------------------------------------------------------

# Remove NA and deduplicate on DOI
scopus_non_NA <- subset(scopus_res_df, !(is.na(DOI))) # N = 8488
scopus_non_NA <- scopus_non_NA[!duplicated(scopus_non_NA$DOI),] # N = 8395
# Add NA records back in 
scopus_res_dedup <- rbind(scopus_non_NA, subset(scopus_res_df, is.na(DOI))) # N = 8395

# Deduplicate on Title
scopus_dedup <- scopus_res_dedup[!duplicated(scopus_res_dedup$Title),] # N = 8359

# Separate into 2021/22
scopus_dedup_2021 <- subset(scopus_dedup, Pub.Year == 2021) # N = 4252
scopus_dedup_2022 <- subset(scopus_dedup, Pub.Year == 2022) # N = 4107


### EXPORT SCOPUS RESULTS ### -------------------------------------------------------------------
# Export Scopus dataframes -> csv
#write.csv(scopus_dedup_2021, "Scopus/Output Files/Scopus_2021_Results_20240126.csv", row.names = FALSE)
#write.csv(scopus_dedup_2022, "Scopus/Output Files//Scopus_2022_Results_20240126.csv", row.names = FALSE)
#write.csv(scopus_dedup, "Scopus/Output Files/Scopus_2021_2022_Results_20240126.csv", row.names = FALSE)
