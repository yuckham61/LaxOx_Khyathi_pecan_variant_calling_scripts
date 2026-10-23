#!/bin/bash
#SBATCH --job-name=gwas
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=200G
#SBATCH --time=24:00:00
#SBATCH --array=0-87%8
#SBATCH --output=/scratch/ad16566/Khyathi_data/Justin_pecan_all_chr_LxO/logs/%x_%A_%a.out
#SBATCH --error=/scratch/ad16566/Khyathi_data/Justin_pecan_all_chr_LxO/logs/%x_%A_%a.err
set -e
module purge
module load GAPIT/3.5-foss-2023a-R-4.3.2
export OPENBLAS_NUM_THREADS=$SLURM_CPUS_PER_TASK

models=(Blink FarmCPU MLM GLM)     # fast models first
traits=(Severity_2023 Incidence_2023 Zn_2023 Severity_2024 Incidence_2024 SPAD_2024 Zn_2024 Severity_2025 Incidence_2025 SPAD_2025 Zn_2025 Severity_2026 Incidence_2026 SPAD_2026 Zn_2026 Zn_mean_23_26 Zn_stdev_23_26 Zn_CV log_transformed_Zn Zn_BLUE BLUE_SE Zn_BLUP)
ntr=${#traits[@]}
m=${models[$((SLURM_ARRAY_TASK_ID / ntr))]}
t=${traits[$((SLURM_ARRAY_TASK_ID % ntr))]}
echo "task $SLURM_ARRAY_TASK_ID: model=$m trait=$t"
Rscript /scratch/ad16566/Khyathi_data/scripts/gapit.R $m $t


## In terminal to see if everything ran smoothly
#sacct -j 48928465 --format=JobID,JobName,State,ExitCode,Elapsed,TotalCPU,MaxRSS

