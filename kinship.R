library(data.table)
library(GAPIT)

base <- "/scratch/ad16566/Khyathi_data/Justin_pecan_all_chr_LxO"
nthreads <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "1"))

myG_pr <- fread(file.path(base, "genotype/LxO_pruned.hmp.txt"),
                header = FALSE, data.table = FALSE, nThread = nthreads)
print(dim(myG_pr))

outdir <- file.path(base, "kinship_results")
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
setwd(outdir)

res <- GAPIT(G = myG_pr, PCA.total = 5, kinship.algorithm = "VanRaden",
             SNP.impute = "Major", file.output = TRUE)
print(names(res))
stopifnot(!is.null(res$KI), !is.null(res$PCA))
saveRDS(list(KI = res$KI, PCA = res$PCA), file.path(outdir, "kin_object.rds"))