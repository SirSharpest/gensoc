library(stats)
library(plyr)
library(dplyr)
library(purrr)
library(readr)
library(ggplot2)

source('~/Documents/GenSoc/QTL Mapping/Code/multiplot.R')

setwd('~/Documents/GenSoc/Data/')

# Read in the CSV files
Tbl <- list.files(path = "./phendata",
                  pattern="*ISQ.csv",
                  recursive = TRUE,
                  full.names = T) %>% 
  map_df(function(f) read_csv(f, col_types = cols(.default = "n")) %>% mutate('Measurement number'=gsub(".ISQ.csv","",basename(f))))

# Remove seeds at awkward angles
Tbl <- Tbl[Tbl$length < quantile(Tbl$length, 0.95),]
Tbl <- Tbl[Tbl$width < 2,]


# Remove fragments of rachis 
Tbl <- Tbl[Tbl$volume > 1,]

# generate ratio of width/length/depth
Tbl$geometry_ratio <- ((Tbl$width / Tbl$length) + (Tbl$width / Tbl$depth)
                       + (Tbl$depth / Tbl$width)+ (Tbl$depth / Tbl$length)
                       + (Tbl$length / Tbl$depth) + (Tbl$length / Tbl$width))

# Normalisation function
norml <- function(x){(x-min(x))/(max(x)-min(x))}
Tbl$geometry_ratio <- norml(Tbl$geometry_ratio) 

# Flip the Z 
Tbl$z <- max(Tbl$z) - Tbl$z 

# Remove crease volume 
Tbl$crease_volume <- NULL

# Rename the filename for matching up
Tbl$'Measurement number' <- substring(Tbl$'Measurement number', 5)
Tbl$'Measurement number' <- as.numeric(Tbl$'Measurement number') + 7


# load matching file
scans2rils <- read_csv('scans_and_RILs_linker.csv', col_types = cols(.default = 'c'))
scans2rils$`Measurement number` <- as.numeric(scans2rils$`Measurement number`) 

# Join up on measurement number
joined = merge(Tbl, scans2rils)

# Remove parent scans 
joined$`RIL ID` <- as.numeric(joined$`RIL ID`)
parents <- joined[is.na(joined$`RIL ID`),]
joined <- joined[!is.na(joined$`RIL ID`),]


# This is just a sanity check really to see what kind of data we are getting
ps<-list()

write_csv(joined, 'individualSeedData.csv')

# Compress data to averages per plant for geno matching
  # Define useable phenotypic columns 
phenotypes <- list(joined$length, joined$width, joined$depth, joined$circularity, joined$volume,
                   joined$crease_depth, joined$surface_area, joined$z, joined$geometry_ratio)

phendata <-aggregate(phenotypes, by=list(joined$`RIL ID`), mean)
colnames(phendata) <- c('RIL','length', 'width', 'depth', 'circularity', 'volume', 'crease_depth', 'surface_area', 'z', 'geometry_ratio') 
write_tsv(phendata, 'meanRILs.tsv')


# Next sort out the genetic map
genmap = read_tsv('Genetic Map/AxB_F8_PreQTLCartographer-Genotypes.tsv', col_types=cols(.default='c'))

# fix naming
colnames(genmap) <- gsub("ABR6 x Bd21 F2-", "", colnames(genmap))
colnames(genmap) <- gsub(" F7-1 F8-1", "", colnames(genmap))
# Set colnames to be numeric values
colnames(genmap)[4:118] <- as.numeric(colnames(genmap)[4:118]) 

# Match up what we have genetic info for and pheno for
mapable_phens <- phendata[phendata$RIL %in% colnames(genmap)[4:118],]

# Write
write_tsv(data.frame(t(mapable_phens)), 'Genetic Map/AxB_F8_PreQTLCartographer-Phenotypes.tsv')


### Some plotting
for (h in colnames(Tbl[1:13])){
  
  if (h == 'Measurement number') next
  
  p <- ggplot(Tbl, aes_string(x=h)) +
    geom_histogram(col="black", 
                   aes(fill=..count..), bins=30) + 
    scale_fill_gradient2("Count", high="red")
  
  ps[[length(ps)+1]] <-p
}
X11()
multiplot(ps[[1]], ps[[2]], ps[[3]], ps[[4]], ps[[5]], ps[[6]],
          ps[[7]], ps[[8]], ps[[9]], ps[[10]], ps[[11]], ps[[12]], cols=2)

