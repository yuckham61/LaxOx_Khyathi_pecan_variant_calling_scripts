#!/bin/bash
#SBATCH --job-name=GAPIT
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=64
#SBATCH --mem=200G
#SBATCH --time=2-10:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -e



# In terminal
# tar -xzf Justin_Lakota_Oaxaca_ref/LakotaXOaxaca_merged_genotypes.tar.gz -C ~/Justin_Lakota_Oaxaca

# Make folder


# For concatenation
#bcftools concat --threads 4 -Ob -o ../../Justin_pecan_all_chr_LxO/LxO_allChr.bcf Chr{01..16}.bcf 2>&1 | grep -v "GP should be"

#bcftools index LxO_allChr.bcf

# Missing rate
#bcftools +fill-tags LxO_allChr.bcf -- -t F_MISSING \
#| bcftools query -f '%CHROM\t%POS\t%F_MISSING\n' \
#> missing_rate.txt
#Tippecanoe4699!

# Minor allele frequency
#bcftools +fill-tags LxO_allChr.bcf -- -t MAF \
#| bcftools query -f '%CHROM\t%POS\t%MAF\n' \
#> maf.txt

##Marker filtering , keeping only biallelic sites, includes sites with MAD of atleast 5%, missing data in fewer than 20&
#bcftools +fill-tags LxO_allChr.bcf -- -t MAF,F_MISSING | \
#bcftools view \
#-m2 -M2 \
#-i 'MAF>=0.05 && F_MISSING<0.20' \
#-Ob -o LxO_0.05MAF_MF20.bcf
#
#

# Rename the vcf file 
#bcftools reheader -s rename_samples.txt -o LxO_0.05MAF_MF20_renamed.bcf LxO_0.05MAF_MF20.bcf



# Load module PLINK

# Convert to Plinnk format


# For LD pruning
#plink2 \
#  --bcf LxO_0.05MAF_MF20_renamed.bcf \
#  --set-all-var-ids @:#:\$r:\$a \
#  --new-id-max-allele-len 1000 truncate \
#  --make-bed \
#  --out LxO_unique


# LD pruning look at 50 variants at a time, and a sliding window of 10 and 2 markers have r2 of 0.8, remove that markers
#plink2 \
#  --bfile LxO_unique \
#  --indep-pairwise 50 10 0.8 \
#  --out prune08

# Extract markers in r2 of 0.8 from above and make PCA
# plink2 \
#  --bfile LxO_unique \
#  --extract prune08.prune.in \
#  --pca 20 \
#  --out PCA


# Convert to vcf
#bcftools view \
#-Oz \
#-o LxO_0.05MAF_MF20_renamed.vcf.gz \
#LxO_0.05MAF_MF20_renamed.bcf




## Run module
#module load R/4.5.1-gfbf-2025a



export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OPENBLAS_NUM_THREADS=$SLURM_CPUS_PER_TASK

## Running GAPIT on sapelo

# Convert vcf file to .hmp.txt file
# Make sure the memory is equal witht the mem from the slurm header
# If the vcf file is huge, ram has to be more to be able to convert that file

#module load TASSEL/5.2.44-Java-1.8.0_241




#ml R-bundle-Bioconductor/3.22-foss-2025a-R-4.5.1
# Module GAPIT

#run_pipeline.pl \
#-Xmx180g \
#-importGuess genotype/LxO_0.05MAF_MF20_renamed.vcf \
#-export genotype/LxO_0.05MAF_MF20_renamed.hmp.txt \
#-exportType Hapmap

module purge
#module load R/4.5.1-gfbf-2025a
module load GAPIT/3.5-foss-2023a-R-4.3.2
Rscript --version
Rscript -e 'library(GAPIT); library(data.table); cat("packages OK\n")'

cd /scratch/ad16566/Khyathi_data/Justin_pecan_all_chr_LxO


Rscript ../scripts/gapit.R
