# Nathan's Version July 2017
library('tictoc')
tic()
# Set working directory
setwd('~/Documents/ABR6xBd21/Rqtl/')

# Read in Rqtl package
library(qtl)

# Read in:
#	(1) Genetic Map
#	(2) Marker Position Information
#	(3) Phenotypic Data
#	(4) Chromosome ID
#	(5) Marker Names
#	(6) Phenotype Names
HM = read.cross(format="qtlcart", file="qtlcart.cro", mapfile="qtlcart.map")

# Calculate genotypic probabilities
HM = calc.genoprob(HM, map.function="kosambi")

# Plot Cross Information
#png(file="figure_2_histograms.png", width=2000, height=2000)
plot(HM)

# generate correlation plot
library(gclus)
png(file="figure_1_correlation_matrix.png", width=2000, height=2000)
dta <- HM$pheno # get data
dta.r <- abs(cor(dta, use="complete.obs")) # get correlations
dta.col <- dmat.color(dta.r) # get colors
dta.o <- order.single(dta.r)
cpairs(dta, dta.o, panel.colors=dta.col, gap=.5, main="Variables Ordered and Colored by Correlation" ) 

# Plot Genotype Information
# note: Similar to MadMapper output
geno.image(HM)

# Plot Marker x Marker
# note: Similar to MadMapper output
png(file="figure_3_ABR6xBd21_recombination_frequency_plot.png", width=1000, height=1000)
plot.rf(HM, what="rf")

# Calculate genotype probabilities and simulate missing data
HM = calc.genoprob(HM, step=2, error.prob=0.001)
HM = sim.geno(HM, step=2, n.draws=128, err=0.001)

# Logistic regression of shattering, peelability, and victorin sensitivity
shattering = scanone(HM, pheno.col=6, model="binary", method="em")
shattering.perm = scanone(HM, pheno.col=6, model="binary", method="em", n.perm=1000)

shattering.hk = scanone(HM, pheno.col=6, model="binary", method="hk")
shattering.perm.hk = scanone(HM, pheno.col=6, model="binary", method="hk", n.perm=1000)

shattering.mr = scanone(HM, pheno.col=6, model="binary", method="mr")
shattering.perm.mr = scanone(HM, pheno.col=6, model="binary", method="mr", n.perm=1000)

png(file="logistic_regression_shattering.png", width=1000, height=500)
plot(shattering, ylim=c(0,4.25))
add.threshold(shattering, perms=shattering.perm, alpha=0.05, col="blue")

summary(shattering.perm, alpha=c(0.05,0.01))
summary(shattering.perm.hk, alpha=c(0.05,0.01))
summary(shattering.perm.mr, alpha=c(0.05,0.01))

peelability = scanone(HM, pheno.col=7, model="binary", method="em")
peelability.perm = scanone(HM, pheno.col=7, model="binary", method="em", n.perm=1000)

png(file="logistic_regression_peelability.png", width=1000, height=500)
plot(peelability, ylim=c(0,4.25))
add.threshold(peelability, perms=peelability.perm, alpha=0.05, col="blue")

victorin = scanone(HM, pheno.col=8, model="binary", method="em")
victorin.perm = scanone(HM, pheno.col=8, model="binary", method="em", n.perm=1000)

png(file="logistic_regression_victorin.png", width=1000, height=500)
plot(victorin)
add.threshold(victorin, perms=victorin.perm, alpha=0.05, col="blue")


# PICK UP FROM HERE IN DATA ANALYSIS!!!!

# seed width V6 pxg plot for major effect QTL
plot.pxg(HM, marker=c("Bd4_27278128"), pheno.col=8)

# seed width V6 pxg plot for major effect QTL
png(file="seed_width_V6_Bd3_2524763_PxG.png")
plot.pxg(HM, marker=c("Bd3_2524763"), pheno.col=8)

plot.pxg(HM, marker=c("Bd3_2524763"), pheno.col=16)

effectplot(HM, pheno.col=1, mname1="Bd3_14749589")
plot.pxg(HM, marker=c("Bd3_14749589"), pheno.col=1)

#plot.pxg(HM, marker=c("Bradi3g16340_p1"), pheno.col=1)

toc()