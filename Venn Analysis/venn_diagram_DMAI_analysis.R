# Install and load necessary packages
install.packages("pacman")
pacman::p_load(ggvenn, venn, ggplot2, ggpolypath)

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

### CREATE DOI/TITLE LISTS ### -------------------------------------------------

# Title list for venn comparison
comb_title <- list(
  DMAI = DMAI_dat$title,
  Scopus = scopus_dat$Title, 
  Lens = lens_dat$Title, 
  AA = aa_affil_dat$Title,
  WoS = wos_dat$Title
)

# DOI list where DOI != NA for venn comparison 
comb_DOI <- list(
  DMAI = DMAI_sep_list[[2]]$doi,
  Scopus = scopus_sep_list[[2]]$DOI,
  Lens = lens_sep_list[[2]]$DOI,
  AA = aa_affil_sep_list[[2]]$DOI,
  WoS = wos_sep_list[[2]]$DOI
)

### GGVENN VISUALIZATIONS ### -------------------------------------------------------
# ggvenn package can only handle 4 sets 

# Venn Diagram between affiliation DOIs where DOI != NA
png("Venn Analysis/DMAI_results/Affiliation_DOI_Venn_Diagram.png")
venn_plot <- ggvenn(
  comb_DOI[2:length(comb_DOI)], 
  fill_color = c("#0073C2FF", "#EFC000FF", "#868686FF", "#CD534CFF"),
  stroke_size = 0.5, set_name_size = 4
)
venn_plot <- venn_plot + 
                labs(title ="Affiliation DOI Venn Diagram",
                    subtitle = "Plot of DOI when DOI is not missing") + 
                theme(plot.title = element_text(face="bold", hjust = 0.5), 
                      plot.subtitle = element_text(face = "italic", hjust = 0.5))
print(venn_plot)
dev.off()


# Venn Diagram between affiliation Titles without filtration
png("Venn Analysis/DMAI_results/Affiliation_Title_Venn_Diagram.png")
venn_plot <- ggvenn(
  comb_title[2:length(comb_title)], 
  fill_color = c("#0073C2FF", "#EFC000FF", "#868686FF", "#CD534CFF"),
  stroke_size = 0.5, set_name_size = 4
)
venn_plot <- venn_plot + labs(title = "Affiliation Title Venn Diagram") + theme(plot.title = element_text(face="bold", hjust = 0.5))
print(venn_plot)
dev.off()


### VENN PACKAGE VISUALIZATIONS ### ----------------------------------------------------------------------
# To show intersection of DMAI, Scopus, Lens, AA, and Wos - need intersection of 5 sets

# Venn Diagram between affiliation DOIs where DOI != NA
png("Venn Analysis/DMAI_results/DMAI_Affiliation_DOI_Venn_Diagram.png")
venn_plot <- venn(
  comb_DOI, 
  ilabels = "counts", 
  zcolor = "#911eb4, #F2CA19, #e6194B, #0057E9, #3cb44b", 
  ggplot = TRUE
)
venn_plot <- venn_plot + 
                labs(title ="Affiliation DOI Venn Diagram",
                     subtitle = "Plot of DOI when DOI is not missing") + 
                theme(plot.title = element_text(face="bold", hjust = 0.5, size = 16, margin = margin(b = 2)), 
                      plot.subtitle = element_text(face = "italic", hjust = 0.5, size = 12, margin = margin(b = -15))) 
print(venn_plot)
dev.off()

# Venn Diagram between affiliation Titles
png("Venn Analysis/DMAI_results/DMAI_Affiliation_Title_Venn_Diagram.png")
venn_plot <- venn(
  comb_title, 
  ilabels = "counts", 
  zcolor = "#911eb4, #F2CA19, #e6194B, #0057E9, #3cb44b", 
  ggplot = TRUE
)
venn_plot <- venn_plot +
                labs(title = "Affiliation Title Venn Diagram") + 
                theme(plot.title = element_text(face="bold", hjust = 0.5, size = 16, margin = margin(b = -15)))
print(venn_plot)
dev.off()  
