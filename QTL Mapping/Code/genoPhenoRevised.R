# Clear data 
rm(list = ls())

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
                  pattern = "*ISQ.csv",
                  recursive = TRUE,
                  full.names = T) %>%
  map_df(function(f) read_csv(f, col_types = cols(.default = "n")) %>% mutate('Measurement number' = gsub(".ISQ.csv", "", basename(f))))


# Remove seeds at awkward angles
Tbl <- Tbl[Tbl$length < quantile(Tbl$length, 0.95),]
Tbl <- Tbl[Tbl$width < 2,]

# Remove fragments of rachis 
Tbl <- Tbl[Tbl$volume > 1,]

# generate ratio of width/length/depth
Tbl$geometry_ratio <- ((Tbl$width / Tbl$length) + (Tbl$width / Tbl$depth)
                       + (Tbl$depth / Tbl$width) + (Tbl$depth / Tbl$length)
                       + (Tbl$length / Tbl$depth) + (Tbl$length / Tbl$width))


# Normalisation function
norml <- function(x) {(x - min(x)) / (max(x) - min(x)) }
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

# Condense down to averages 

## define population phenotypes
phenotypes <- list(joined$length, joined$width, joined$depth, joined$circularity, joined$volume,
                   joined$crease_depth, joined$surface_area, joined$z, joined$geometry_ratio, joined$grain_count)

## Median
phendataMedian <- aggregate(phenotypes, by = list(joined$`RIL ID`), median)
colnames(phendataMedian) <- c('RIL', 'median_length',
                              'median_width', 'median_depth',
                              'median_circularity', 'median_volume',
                              'median_crease_depth', 'median_surface_area',
                              'median_z', 'median_geometry_ratio', 'median_grain_count')
## Standard Error
phendataSE <- aggregate(phenotypes, by = list(joined$`RIL ID`), std.error)
colnames(phendataSE) <- c('RIL', 'se_length',
                              'se_width', 'se_depth',
                              'se_circularity', 'se_volume',
                              'se_crease_depth', 'se_surface_area',
                              'se_z', 'se_geometry_ratio', 'se_grain_count')


## Mode function
Mode <- function(x) {
    ux <- unique(x)
    ux[which.max(tabulate(match(x, ux)))]
}

phendataMode <- aggregate(phenotypes, by = list(joined$`RIL ID`), Mode)
colnames(phendataMode) <- c('RIL', 'mode_length',
                              'mode_width', 'mode_depth',
                              'mode_circularity', 'mode_volume',
                              'mode_crease_depth', 'mode_surface_area',
                              'mode_z', 'mode_geometry_ratio', 'mode_grain_count')

phendataMin <- aggregate(phenotypes, by = list(joined$`RIL ID`), min)
colnames(phendataMin) <- c('RIL', 'min_length',
                              'min_width', 'min_depth',
                              'min_circularity', 'min_volume',
                              'min_crease_depth', 'min_surface_area',
                              'min_z', 'min_geometry_ratio', 'min_grain_count')


phendataMax <- aggregate(phenotypes, by = list(joined$`RIL ID`), max)
colnames(phendataMax) <- c('RIL', 'max_length',
                              'max_width', 'max_depth',
                              'max_circularity', 'max_volume',
                              'max_crease_depth', 'max_surface_area',
                              'max_z', 'max_geometry_ratio', 'max_grain_count')



phendata <- merge(phendataMedian, phendataSE)
phendata <- merge(phendata, phendataMax)
phendata <- merge(phendata, phendataMode)
phendata <- merge(phendata, phendataMin)


# Match up with the geno info that we have 

# Next sort out the genetic map
genmap = read_tsv('Genetic Map/Cartographer files/AxB_F8_PreQTLCartographer-Genotypes.tsv', col_types = cols(.default = 'c'))

# fix naming
colnames(genmap) <- gsub("ABR6 x Bd21 F2-", "", colnames(genmap))
colnames(genmap) <- gsub(" F7-1 F8-1", "", colnames(genmap))
# Set colnames to be numeric values
colnames(genmap)[4:118] <- as.numeric(colnames(genmap)[4:118])

# Match up what we have genetic info for and pheno for
mapable_phens <- phendata[phendata$RIL %in% colnames(genmap)[4:118],]

write.table(t(mapable_phens), file = 'Genetic Map/Cartographer files/AxB_F8_PreQTLCartographer_phenotypes-extended.tsv',
    quote = FALSE, sep = '\t', col.names = NA)