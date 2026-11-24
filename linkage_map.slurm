#!/bin/bash
#SBATCH --job-name=order_lakota
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --time=4-10:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -e

#Make directory
cd /scratch/ad16566/Khyathi_data/Linkage_mapping_lepmap3

# Create folders
mkdir -p logs/
mkdir -p lakota_LG

# Load module
# Load Java
module load Java/17.0.6

LM3_BIN=/scratch/ad16566/lepmap3/binary+code/bin

# Order for Lakota (informativeMask=2), one chromosome per node, in parallel
#java -cp ${LM3_BIN} OrderMarkers2 map=map_js.txt data=file.call informativeMask=2 useKosambi=1 outputPhasedData=2 numThreads=32 identicalLimit=0.005 > Lakota_order.txt



# Order for Oaxaca (informativeMask=1), one chromosome per node, in parallel
#java -cp ${LM3_BIN} OrderMarkers2 map=map_js.txt data=file.call informativeMask=1 useKosambi=1 outputPhasedData=2 numThreads=32 identicalLimit=0.005 > Oaxaca_order.txt


# RUNNING THIS IN TERMINAL
# To identify problematic individuals
#tail -30 logs/linkage_mapping_48323386.err
#grep -i -n "recomb" logs/linkage_mapping_48323386.err | head -30

# To find where one parents recombination starts
#grep -n "Loading file" logs/linkage_mapping_48323386.err

#sed -n '1,8260p' logs/linkage_mapping_48323386.err > lakota_full.err
#sed -n '8261,$p' logs/linkage_mapping_48323386.err > oaxaca_full.err

#awk '/recombines/ {sum[$3]+=$5} END{for (i in sum) print i, sum[i]}' lakota_full.err | sort -k2 -rn > lakota_recomb_totals.txt
#awk '/recombines/ {sum[$3]+=$5} END{for (i in sum) print i, sum[i]}' oaxaca_full.err | sort -k2 -rn > oaxaca_recomb_totals.txt
#head -20 lakota_recomb_totals.txt
#head -20 oaxaca_recomb_totals.txt
#wc -l lakota_recomb_totals.txt oaxaca_recomb_totals.txt

# Filtering those unusual individuals from vcf using 
#vcftools --vcf LaxOa_final.vcf \
#  --remove-indv 140 --remove-indv 193 --remove-indv 204 --remove-indv 224 \
#  --recode --recode-INFO-all \
#  --out LaxOa_filtered



# parentcall2
java -cp ${LM3_BIN} ParentCall2 \
  data=pedigree_for_pangenome.txt \
  vcfFile=LxO_0.05MAF_MF20_pangenome.vcf \
  removeNonInformative=1 \
  > file_filtered.call

#java -cp ${LM3_BIN} SeparateChromosomes2 \
#  data=file_filtered.call \
#  lodLimit=30 \
#  sizeLimit=100 \
#  distortionLod=1 \
#  numThreads=16 \
#  > map_filtered.txt


#Run this on terminal
#sort map.txt|uniq -c|sort -n  

#java -cp ${LM3_BIN} JoinSingles2All \
#  map=map_filtered.txt \
#  data=file_filtered.call \
#  lodLimit=10 \
#  lodDifference=2 \
#  distortionLod=1 \
#  iterate=1 \
#  numThreads=4 \
#  > map_js_filtered.txt

# In terminal
#cut -f1 map_js_filtered.txt | sort | uniq -c | sort -n



#OrderMarker2
java -cp ${LM3_BIN} OrderMarkers2 map=map_js_filtered.txt data=file_filtered.call informativeMask=2 useKosambi=1 outputPhasedData=2 numThreads=8 identicalLimit=0.005 > Lakota_order_filtered.txt
#java -cp ${LM3_BIN} OrderMarkers2 map=map_js_filtered.txt data=file_filtered.call informativeMask=1 useKosambi=1 outputPhasedData=2 numThreads=32 identicalLimit=0.005 > Oaxaca_order_filtered.txt

# convert ordermarkers to output file
awk -v fullData=1 -f "${LM3_BIN}/map2genotypes.awk" Lakota_order_filtered.txt > Lakota_genotypes.txt
#awk -v fullData=1 -f "${LM3_BIN}/map2genotypes.awk" Oaxaca_order_filtered.txt > Oaxaca_genotypes.txt

#{|HW=HZ63-M#,KUY%-HCY_7TmwGg)QP,

