# Clear data 
rm(list=ls())

library(stats)
library(plyr)
library(dplyr)
library(purrr)
library(readr)
library(ggplot2)
library(scales)
library(plotrix)


# Setup working dir
setwd('C:/Users/Nathan/Google Drive/GenSoc/Data/')

# Read in the CSV files
Tbl <- list.files(path = "Phenotypic Data/CT Data/Single Heads",
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

# add count to Tbl for grains
count <- rle(sort(Tbl$`Measurement number`))
Tbl$grain_count <- count[[1]][match(Tbl$`Measurement number`, count[[2]])]

# load matching file
scans2rils <- read_csv('Scanning Information/scans_and_RILs_linker.csv', col_types = cols(.default = 'c'))
scans2rils$`Measurement number` <- as.numeric(scans2rils$`Measurement number`) 

# Join up on measurement number
joined = merge(Tbl, scans2rils)

# Remove parent scans 
joined$`RIL ID` <- as.numeric(joined$`RIL ID`)
parents <- joined[is.na(joined$`RIL ID`),]
joined <- joined[!is.na(joined$`RIL ID`),]

# Compress data to averages per plant for geno matching
  # Define useable phenotypic columns 

# divide parents 
abr6 <- parents[parents$`Plant number`=='BD_01504',]
abr6$`RIL ID` <- 'abr6'
bd21 <- parents[parents$`Plant number`=='BD_01505',]
bd21$`RIL ID` <- 'bd21'
# define population phenotypes
phenotypes <- list(joined$length, joined$width, joined$depth, joined$circularity, joined$volume,
                   joined$crease_depth, joined$surface_area, joined$z, joined$geometry_ratio, joined$grain_count)

# parental phenotypes 
abr6_phenotypes <- list(abr6$length, abr6$width, abr6$depth, abr6$circularity, abr6$volume,
                   abr6$crease_depth, abr6$surface_area, abr6$z, abr6$geometry_ratio, abr6$grain_count)
bd21_phenotypes <- list(bd21$length, bd21$width, bd21$depth, bd21$circularity, bd21$volume,
                        bd21$crease_depth, bd21$surface_area, bd21$z, bd21$geometry_ratio, bd21$grain_count)

# Get medians
abr6Median <- aggregate(abr6_phenotypes, by=list(abr6$`RIL ID`), median)
colnames(abr6Median) <- c('RIL','median_length', 
                              'median_width', 'median_depth',
                              'median_circularity', 'median_volume',
                              'median_crease_depth', 'median_surface_area',
                              'median_z', 'median_geometry_ratio', 'median_grain_count') 

bd21Median <- aggregate(bd21_phenotypes, by=list(bd21$`RIL ID`), median)
colnames(bd21Median) <- c('RIL','median_length', 
                          'median_width', 'median_depth',
                          'median_circularity', 'median_volume',
                          'median_crease_depth', 'median_surface_area',
                          'median_z', 'median_geometry_ratio', 'median_grain_count') 


phendataMedian <- aggregate(phenotypes, by=list(joined$`RIL ID`), median)
colnames(phendataMedian) <- c('RIL','median_length', 
                              'median_width', 'median_depth',
                              'median_circularity', 'median_volume',
                              'median_crease_depth', 'median_surface_area',
                              'median_z', 'median_geometry_ratio', 'median_grain_count') 

# get SE and merge
abr6SE <- aggregate(abr6_phenotypes, by=list(abr6$`RIL ID`), std.error) 
colnames(abr6SE) <- c('RIL','se_length', 
                          'se_width', 'se_depth',
                          'se_circularity', 'se_volume',
                          'se_crease_depth', 'se_surface_area',
                          'se_z', 'se_geometry_ratio', 'se_grain_count') 
abr6_phendata <- merge(abr6Median, abr6SE)

bd21SE <- aggregate(bd21_phenotypes, by=list(bd21$`RIL ID`), std.error) 
colnames(bd21SE) <- c('RIL','se_length', 
                      'se_width', 'se_depth',
                      'se_circularity', 'se_volume',
                      'se_crease_depth', 'se_surface_area',
                      'se_z', 'se_geometry_ratio', 'se_grain_count') 
bd21_phendata <- merge(bd21Median, bd21SE)


phendataSE <- aggregate(phenotypes, by=list(joined$`RIL ID`), std.error) 
colnames(phendataSE) <- c('RIL','se_length', 
                              'se_width', 'se_depth',
                              'se_circularity', 'se_volume',
                              'se_crease_depth', 'se_surface_area',
                              'se_z', 'se_geometry_ratio', 'se_grain_count') 
phendata <- merge(phendataMedian, phendataSE)

write_tsv(phendata, 'Phenotypic Data/Compiled Data/medianRILs.tsv')

# Next sort out the genetic map
genmap = read_tsv('Genetic Map/Cartographer files/AxB_F8_PreQTLCartographer-Genotypes.tsv', col_types=cols(.default='c'))

# fix naming
colnames(genmap) <- gsub("ABR6 x Bd21 F2-", "", colnames(genmap))
colnames(genmap) <- gsub(" F7-1 F8-1", "", colnames(genmap))
# Set colnames to be numeric values
colnames(genmap)[4:118] <- as.numeric(colnames(genmap)[4:118]) 

# Match up what we have genetic info for and pheno for
mapable_phens <- phendata[phendata$RIL %in% colnames(genmap)[4:118],]

# Write
write_tsv(data.frame(t(mapable_phens)), 'Genetic Map/Cartographer files/AxB_F8_PreQTLCartographer-Phenotypes.tsv')



