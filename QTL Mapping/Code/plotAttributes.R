# Throws together silly multiplots
# requires genereatePhenoData to be called first
# to setup some of the variables


setwd('C:/Users/Nathan/Google Drive/GenSoc/Data/')

source('C:/Users/Nathan/Google Drive/GenSoc/QTL Mapping/Code/multiplot.R')

# This is just a sanity check really to see what kind of data we are getting

ps1 <- list()

### Some plotting
for (h in c('length',
            'width', 'depth',
            'circularity', 'volume',
            'crease_depth', 'surface_area',
            'z', 'geometry_ratio')) {


    bd <- data.frame(bd21[, h])
    colnames(bd) <- h
    abr <- data.frame(abr6[, h])
    colnames(abr) <- h
    cross <- data.frame(joined[, h])
    colnames(cross) <- h

    bd$source <- 'bd21'
    abr$source <- 'abr6'
    cross$source <- 'cross'

    attribute <- rbind.fill(bd, abr, cross)

    p <- ggplot(attribute, aes_string(h, fill = 'source')) +
    geom_density(alpha = 0.5, aes(y = ..density..), position = 'identity')

    ps1[[length(ps1) + 1]] <- p
}

multiplot(ps1[[1]], ps1[[2]], ps1[[3]], ps1[[4]], ps1[[5]], ps1[[6]],
          ps1[[7]], ps1[[8]], ps1[[9]], cols = 2)

ps <- list()

### Some plotting
for (h in c('median_length',
            'median_width', 'median_depth',
            'median_circularity', 'median_volume',
            'median_crease_depth', 'median_surface_area',
            'median_z', 'median_geometry_ratio', 'median_grain_count')) {


    p <- ggplot(phendata, aes_string(x = h)) +
    geom_histogram(col = "black",
                   aes(fill = ..count..), bins = 15) +
    scale_fill_gradient2("Count", high = "blue")


    ps[[length(ps) + 1]] <- p
}

multiplot(ps[[1]], ps[[2]], ps[[3]], ps[[4]], ps[[5]], ps[[6]],
          ps[[7]], ps[[8]], ps[[9]], ps[[10]], cols = 2)


pse <- list()





for (h in c('se_length',
            'se_width', 'se_depth',
            'se_circularity', 'se_volume',
            'se_crease_depth', 'se_surface_area',
            'se_z', 'se_geometry_ratio', 'se_grain_count')) {


    p <- ggplot(phendata, aes_string(x = h)) +
    geom_histogram(col = "black",
                   aes(fill = ..count..), bins = 15) +
    scale_fill_gradient2("Count", high = "blue")

    pse[[length(pse) + 1]] <- p
}

multiplot(pse[[1]], pse[[2]], pse[[3]], pse[[4]], pse[[5]], pse[[6]],
          pse[[7]], pse[[8]], pse[[9]], pse[[10]], cols = 2)
