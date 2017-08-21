# Grabs marvin data and tries to make sense of it 

library(stats)
library(plyr)
library(dplyr)
library(purrr)
library(readr)
library(ggplot2)
library(scales)
library(plotrix)

# Setup working dir
setwd('/home//nathan/Google Drive/GenSoc/Data/')

# Read in the CSV files
Tbl <- list.files(path = "Phenotypic Data/Marvin Data/F8 RILS",
                  pattern = "BD_01",
                  recursive = FALSE,
                  full.names = T) %>% 
  map_df(function(f) read_csv(f, col_types = cols(.default = "c"),  local=locale(encoding="latin1") ) %>% mutate('RIL-ID'=gsub("csv","",basename(f))))

# Take columns of interest
Tbl <- Tbl[,3:6]

# Remove diving names 
Tbl$`RIL-ID` <- gsub( '.{5}$' ,'' ,Tbl$`RIL-ID`)

