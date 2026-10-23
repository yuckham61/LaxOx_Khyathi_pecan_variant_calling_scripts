library(data.table)
library(GAPIT)

nthreads <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "1"))

myY <- read.csv("phenotype/Bud_break_phenotypes.csv", header = TRUE, check.names = FALSE)

myG <- fread("genotype/LxO_0.05MAF_MF20_renamed.hmp.txt",
             header = FALSE, data.table = FALSE, nThread = nthreads)

kin  <- readRDS("kinship_out/kin_object.rds")
myKI <- kin$KI
myCV <- kin$PCA[, 1:6]            # taxa + PC1-PC5; confirm columns with head()

# Names must match everywhere
taxa_G <- as.character(unlist(myG[1, 12:ncol(myG)]))
stopifnot(all(myKI[, 1] %in% taxa_G), all(myCV[, 1] %in% taxa_G),
          all(myY$taxa %in% taxa_G))

dir.create("gwas_out"); setwd("gwas_out")

myGAPIT <- GAPIT(
  Y  = myY[, c("taxa","2023_BI","2024_BI","2025_BI","Mean_z")],
  G  = myG,            # full marker set
  KI = myKI,           # kinship from pruned markers
  CV = myCV,           # PCs from pruned markers
  PCA.total = 0,       # don't recompute PCs from the full set
  model = c("MLM", "FarmCPU", "Blink", "GLM"),
  SNP.impute = "Major",
  Inter.Plot = FALSE, PCA.3d = FALSE, file.output = TRUE
)


