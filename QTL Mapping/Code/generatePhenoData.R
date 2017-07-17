library(stats)
library(dplyr)
library(purrr)
library(readr)
library(ggplot2)
source('multiplot.R')

setwd('~/Documents/GenSoc/Data/')

# Read in the CSV files
Tbl <- list.files(path = "./phendata",
                  pattern="*ISQ.csv",
                  recursive = TRUE,
                  full.names = T) %>% 
  map_df(function(f) read_csv(f, col_types = cols(.default = "c")) %>% mutate(filename=gsub(".ISQ.csv","",basename(f))))

# Convert to numeric where needed
Tbl[, 1:12] <- sapply(Tbl[,1:12], as.numeric)

# Remove seeds at awkward angles
Tbl <- Tbl[Tbl$length < quantile(Tbl$length, 0.95),]
Tbl <- Tbl[Tbl$width < 2,]

# Remove fragments of rachis 
Tbl <- Tbl[Tbl$volume > 1,]

# Flip the Z 
Tbl$z <- max(Tbl$z) - Tbl$z 

# Remove crease volume 
Tbl$crease_volume <- NULL

# Grab a list of headings
headings <- colnames(Tbl[1:12])
ps<-list()

for (h in headings){
  p <-ggplot(Tbl, aes_string(x=h)) + geom_histogram()
  ps[[length(ps)+1]] <-p
}

multiplot(ps[[1]], ps[[2]], ps[[3]], ps[[4]], ps[[5]], ps[[6]],
          ps[[7]], ps[[8]], ps[[9]], ps[[10]], ps[[11]], cols=2)
