#!/bin/bash
#SBATCH --job-name=kin
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=100G
#SBATCH --time=12:00:00
#SBATCH --output=/scratch/ad16566/Khyathi_data/Justin_pecan_all_chr_LxO/logs/%x_%j.out
#SBATCH --error=/scratch/ad16566/Khyathi_data/Justin_pecan_all_chr_LxO/logs/%x_%j.err
set -e
module purge
module load GAPIT/3.5-foss-2023a-R-4.3.2
export OPENBLAS_NUM_THREADS=$SLURM_CPUS_PER_TASK
BASE=/scratch/ad16566/Khyathi_data/Justin_pecan_all_chr_LxO
Rscript $BASE/../scripts/kinship.R