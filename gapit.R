library(data.table)
library(GAPIT)

base  <- "/scratch/ad16566/Khyathi_data/Justin_pecan_all_chr_LxO"
args  <- commandArgs(trailingOnly = TRUE)
model <- args[1]
trait <- args[2]
geno  <- if (length(args) >= 3) args[3] else
         file.path(base, "genotype/LxO_0.05MAF_MF20_renamed.hmp.txt")
tag   <- if (length(args) >= 4) args[4] else "full"
stopifnot(model %in% c("GLM","MLM","FarmCPU","Blink"),
          trait %in% c("Severity_2023","Incidence_2023","Zn_2023","Severity_2024","Incidence_2024","SPAD_2024","Zn_2024","Severity_2025","Incidence_2025","SPAD_2025","Zn_2025","Severity_2026","Incidence_2026","SPAD_2026","Zn_2026","Zn_mean_23_26","Zn_stdev_23_26","Zn_CV","log_transformed_Zn","Zn_BLUE","BLUE_SE","Zn_BLUP"))

# ---- Phenotypes ----
myY <- read.csv(file.path(base, "phenotype/khyathi_zn.csv"),
                header = TRUE, check.names = FALSE)
stopifnot(all(c("taxa", trait) %in% names(myY)))

# ---- Genotypes (full marker set) ----
myG <- fread(geno, header = FALSE, data.table = FALSE, nThread = 1)
cat("Genotype table:", dim(myG), "\n")

# ---- Kinship and PCs from the LD-pruned set ----
kdir <- file.path(base, "kinship_results")

myKI <- fread(file.path(kdir, "GAPIT.Genotype.Kin_VanRaden.csv"),
              header = FALSE, data.table = FALSE)       # no header; taxa in column 1
pcs  <- fread(file.path(kdir, "GAPIT.Genotype.PCA.csv"),
              header = TRUE, data.table = FALSE)         # taxa, PC1..PC5
myCV <- pcs[, 1:6]                                       # taxa + PC1-PC5

cat("KI:", dim(myKI), "  CV:", dim(myCV), "\n")
stopifnot(nrow(myKI) == ncol(myKI) - 1)                  # square matrix + taxa column
stopifnot(identical(as.character(myKI[, 1]), as.character(myCV[, 1])))

# ---- Sample names must match everywhere ----
taxa_G <- as.character(unlist(myG[1, 12:ncol(myG)]))
cat("genotyped samples:", length(taxa_G), "\n")
stopifnot(all(myKI[, 1] %in% taxa_G), all(myCV[, 1] %in% taxa_G))
n_both <- sum(myY$taxa %in% taxa_G)
cat("phenotyped and genotyped:", n_both, " | phenotyped but not genotyped:",
    nrow(myY) - n_both, "\n")
stopifnot(n_both > 0)

# ---- Run GAPIT in its own output folder ----
outdir <- file.path(base, "GWAS_results", paste0(tag, "_", model, "_", trait))
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
setwd(outdir)

res <- GAPIT(
  Y = myY[, c("taxa", trait)],
  G  = myG,              # full marker set
  KI = myKI,             # kinship from pruned markers
  CV = myCV,             # PCs from pruned markers
  PCA.total = 0,         # don't recompute PCs from the full set
  model = model,         # one model per array task
  SNP.impute = "Major",
  Inter.Plot = FALSE, PCA.3d = FALSE, file.output = TRUE
)
cat("Finished", model, "\n")