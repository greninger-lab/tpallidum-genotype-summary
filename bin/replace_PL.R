#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE) 
#invoke with RScript --vanillia ./replacePL $base

library(tidyverse)
library(reshape2)

#sample <- "CP004010" for testing: can make mini bp gvcf that recapitulates by head -10000 XX.vcf > XXmini.vcf
sample <- args[1]

#right now this is written to assume that this script resides in same folder as the vcfs, will need a redirect
vcf <- read_tsv(paste0(sample, "_remap.g.vcf"), comment="##")

delim <- as.data.frame(str_split_fixed(vcf[[10]], ":", 5))

#NOTE: This version is ONLY to make per position vcfs, which have depth field in V3. Banded gvcfs have it in V2. 
delim$fakePL <- round(as.numeric(delim$V3)*5.5,0)   #DP in column 2


delim$fakePL2 <- ifelse(delim$fakePL > 1800, 1800, delim$fakePL)
delim$replacePL <- paste0(delim$V1, ":", delim$V2, ":", delim$V3, ":", delim$V4, ":0,", delim$fakePL2)
delim$alt <- vcf$ALT
delim$original <- vcf[[10]]



for (i in 1:nrow(delim)) {
  delim$new[i] <- ifelse(delim$alt[i] == "<NON_REF>" && delim$V5[i] == "0,0", delim$replacePL[i], delim$original[i])
}

vcf[[10]] <- delim$new
write_tsv(vcf, paste0(sample, "_remap_manual.g.vcf"), col_names=FALSE)
