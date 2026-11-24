#!/bin/bash
#SBATCH --job-name=Haplotype_phasing_minimap
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=2-06:00:00                     # time for ONE sample (each array task = one sample)
#SBATCH --array=1-1149%60                   # 1300 samples, at most 60 running at once
#SBATCH --output=/scratch/ad16566/Khyathi_data/logs/align_%A_%a.out
#SBATCH --error=/scratch/ad16566/Khyathi_data/logs/align_%A_%a.err
#SBATCH --mail-user=ad16566@uga.edu
#SBATCH --mail-type=END,FAIL

set -euo pipefail                           # stop on any error, also inside the minimap2 | awk pipe

# BEFORE SUBMITTING (run once on the login node):
#   cd /scratch/ad16566/Khyathi_data
#   ls raw_data/*.txt.trimmed_seqs.txt > sample_list.txt
#   wc -l sample_list.txt                   -> set --array=1-<that number>%60 above
# Then submit:  sbatch LaxOa_align_array.sh


#Set output directory variable
OUTDIR="/scratch/ad16566/Khyathi_data"
REFDIR="/scratch/ad16566/Khyathi_data/reference_genome"
COMBDIR="$OUTDIR/LaxOa_combined_reference"
RAWDIR="$OUTDIR/raw_data"
PAF="$OUTDIR/minimap2_results/paf"
FILTPAF="$OUTDIR/minimap2_results/filtered_paf"
MARKERDIR="$OUTDIR/minimap2_results/markers"
SAMPLELIST="$OUTDIR/sample_list.txt"

# Make sub-directory
mkdir -p "$OUTDIR/logs"
mkdir -p "$PAF"
mkdir -p "$FILTPAF"
mkdir -p "$MARKERDIR"

# Load modules
# Load minimap
module load minimap2/2.29-GCCcore-13.3.0



# Got bunch of instruction from DR. Lovell, and started working with this pipeline on 07/23/2026
# Previously used BWA mem for alignment, but should have used minimap
#################################################################################################################################
# COMBINE ALL 4 GENOME ASSEMBLIES TO ONE FASTA using [cultivarName]_[hapName]_[ChrID]
# (already done - kept here for the record)

#OUT="$COMBDIR/combined_reference.fasta"
#> "$OUT"

#awk '/^>/ { print ">Lakota_Major_" substr($0,2); next } { print }' \
#    "$REFDIR/Carya_illinoinensis_var_Lakota_Major.mainGenome.fasta" >> "$OUT"

#awk '/^>scaffold/ { skip=1; next }
#     /^>Chr/      { skip=0; print ">Lakota_Mahan_" substr($0,2); next }
#     !skip        { print }' \
#    "$REFDIR/Carya_illinoinensis_var_Lakota_Mahan.mainGenome.fasta" >> "$OUT"
#
#awk '/^>scaffold/ { skip=1; next }
#     /^>Chr/      { skip=0; print ">Oaxaca_Hap1_" substr($0,2); next }
#     !skip        { print }' \
#    "$REFDIR/Carya_illinoinensis_var_87MX3.HAP1.mainGenome.fasta" >> "$OUT"
#
#awk '/^>scaffold/ { skip=1; next }
#     /^>Chr/      { skip=0; print ">Oaxaca_Hap2_" substr($0,2); next }
#     !skip        { print }' \
#    "$REFDIR/Carya_illinoinensis_var_87MX3.HAP2.mainGenome.fasta" >> "$OUT"

## At the end of this, there should be the single reference file with [cultivarName]_[hapName]_[ChrID]
# I have checked the sequence number, scaffaold and header, everything looks good while concating.


# Index the concatenated reference file (already done - kept here for the record)
# -I 10G keeps the whole 4-haplotype reference in ONE index part, so MAPQ compares all 4 haplotypes
#minimap2 -x sr -I 10G -t 8 -d "$COMBDIR/combined_reference.mmi" "$COMBDIR/combined_reference.fasta"


###################################################################################################################
# Align the reads to the combined reference fasta
#ALIGN GBS READS TO COMBINED REFERENCE USING MINIMAP2
# -x sr = short read preset
# -p .99 = only report secondary alignments within 99% of best score
# Filter the reads on the basis of mapping quality
# Filter: keep only MAPQ == 60 (uniquely mapping reads)
#Keeping the secondary alignment

# Each array task aligns ONE sample: line number SLURM_ARRAY_TASK_ID of sample_list.txt
file=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLELIST")
sample=$(basename "$file" .txt.trimmed_seqs.txt)
out="$PAF/${sample}.filtered.paf"

# Skip samples that are already done (e.g. the first 300)
if [ -s "$out" ]; then
    echo "$sample already done, skipping"
    exit 0
fi

echo "Aligning $sample"
minimap2 -x sr -p .99 -t 4 \
    "$COMBDIR/combined_reference.mmi" \
    "$file" | \
    awk '$12 == 60' \
    > "${out}.tmp"

# Rename only when finished, so a half-written file is never taken as done
mv "${out}.tmp" "$out"
echo "$sample done: $(wc -l < "$out") MAPQ-60 alignments"