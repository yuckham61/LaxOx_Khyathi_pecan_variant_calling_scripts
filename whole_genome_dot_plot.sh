#!/bin/bash
#SBATCH --job-name=dot_plot
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=32G
#SBATCH --time=2-10:00:00
#SBATCH --output=/scratch/ad16566/Khyathi_data/logs/%x_%j.out
#SBATCH --error=/scratch/ad16566/Khyathi_data/logs/%x_%j.err

set -e


#Set output directory variable
OUTDIR="/scratch/ad16566/Khyathi_data"
REFDIR="/scratch/ad16566/Khyathi_data/reference_genome"
REF_FASTA="$REFDIR/Carya_illinoinensis_var_Lakota_Mahan.mainGenome.fasta"
PAFDIR="$OUTDIR/dot_plots_results"
DOTPLOTLY="$OUTDIR/dotPlotly/pafCoordsDotPlotly.R"

# Make sub-directory
mkdir -p "$OUTDIR/logs"
mkdir -p "$OUTDIR/dot_plots_results"


#Load module minimap2
#module load minimap2/2.29-GCCcore-13.3.0
#module load Perl/5.36.1-GCCcore-12.3.0
module purge
module load R/4.5.1-gfbf-2025a




#minimap2 -x asm5 -t 20 "$REF_FASTA" "$REFDIR/Carya_illinoinensis_var_Lakota_Major.mainGenome.fasta" > "$OUTDIR/dot_plots_results/Major_vs_Mahan_wholegenome.paf"
#minimap2 -x asm5 -t 20 "$REF_FASTA" "$REFDIR/Carya_illinoinensis_var_87MX3.HAP2.mainGenome.fasta" > "$OUTDIR/dot_plots_results/Hap2_vs_Mahan_wholegenome.paf"
#minimap2 -x asm5 -t 20 "$REF_FASTA" "$REFDIR/Carya_illinoinensis_var_87MX3.HAP1.mainGenome.fasta" > "$OUTDIR/dot_plots_results/Hap1_vs_Mahan_wholegenome.paf"

