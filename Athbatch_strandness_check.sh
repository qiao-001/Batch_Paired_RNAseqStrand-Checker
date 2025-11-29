#!/bin/bash
# Batch identification of strandness for raw RNA-seq data (paired-end fastq)
start_time=$(date +"%Y-%m-%d %H:%M:%S")
receiver="your email address"  # Email address to receive notifications


###########################################################################
# Step 1: User-defined parameters (modify according to your data!)
###########################################################################
RAW_DATA_DIR="./1raw_data"       # Directory for raw fastq files (paired-end files: *_1.fastq.gz/*_2.fastq.gz)
REF_INDEX="1.1Araref/Arahisat24"  # Path to Hisat2 reference genome index (without suffix)
ANNOTATION_BED="1.1Araref/Arabisopsis-RSeQC.bed" # Gene annotation BED file (corresponding to reference genome)
SAMPLE_SUFFIX="_1.fastq.gz"     # Suffix for paired-end file 1 (must match your naming convention)
THREADS=8                       # Number of threads (adjust according to CPU cores, e.g., 8 for 8-core)
SAMPLE_READS=300000             # Number of sampled reads per sample (200k is sufficient, can be changed to 100k/300k)
OUTPUT_CSV="Ara_200kstrandness_summary.csv" # Result summary CSV file

###########################################################################
# Step 2: Initialize result file (header)
###########################################################################
echo "Sample_Name,Fraction_Failed,A_FR_mode(A=1++,1--,2+-,2-+),B_RF_mode(B=1+-,1-+,2++,2--),A-B_diff,Strandness_Type,Recommended_StringTie_Param" > $OUTPUT_CSV

###########################################################################
# Step 3: Batch process each sample
###########################################################################
# Loop through all paired-end samples (marked by _1.fastq.gz)
for fastq1 in ${RAW_DATA_DIR}/*${SAMPLE_SUFFIX}; do
    # Extract sample name (remove path and _1.fastq.gz suffix)
    sample=$(basename $fastq1 ${SAMPLE_SUFFIX})
    fastq2=${RAW_DATA_DIR}/${sample}_2.fastq.gz  # Path to paired-end file 2
    
    # Check if paired-end file 2 exists
    if [ ! -f "$fastq2" ]; then
        echo "Warning: Sample $sample is missing paired-end file 2 ($fastq2), skipping!"
        continue
    fi
    
    echo "========================================"
    echo "Starting processing sample: $sample"
    echo "Paired-end file 1: $fastq1"
    echo "Paired-end file 2: $fastq2"
    
    #######################################################################
    # 1. Sampling: Extract $SAMPLE_READS reads from each paired-end fastq (temporary files, deleted after processing)
    #######################################################################
    echo "Sampling ($SAMPLE_READS reads/end)..."
    temp_fastq1="./temp_${sample}_1.fastq.gz"
    temp_fastq2="./temp_${sample}_2.fastq.gz"
    
    # Sampling (zcat to decompress ¡ú head to get first N lines ¡ú gzip to compress; number of paired-end reads = lines/4, so N = SAMPLE_READS * 4)
    zcat $fastq1 | head -n $((SAMPLE_READS * 4)) | gzip > $temp_fastq1
    zcat $fastq2 | head -n $((SAMPLE_READS * 4)) | gzip > $temp_fastq2
    
    #######################################################################
    # 2. Hisat2 rapid alignment: Generate only temporary BAM (no sorting for speedup)
    #######################################################################
    echo "Performing rapid alignment (sampled data)..."
    temp_bam="./temp_${sample}.bam"
    
    # Note: No comments after backslash \, comments on separate lines
    hisat2 -p $THREADS -x $REF_INDEX \
           -1 $temp_fastq1 -2 $temp_fastq2 \
           --sensitive --no-unal \
           | samtools view -@$THREADS -b -o $temp_bam
    # Note: --no-unal: Do not output unaligned reads to speed up; pipe directly to samtools to generate BAM (unsorted)
    
    #######################################################################
    # 3. Determine strandness using infer_experiment
    #######################################################################
    echo "Determining strandness..."
    infer_result=$(python3 infer_experiment.py -i $temp_bam -r $ANNOTATION_BED)
    
    #######################################################################
    # 4. Extract key metrics (failure rate, proportions of two modes)
    #######################################################################
    # Extract failure rate (Fraction of reads failed to determine)
    fraction_failed=$(echo "$infer_result" | grep "Fraction of reads failed to determine" | awk '{print $NF}')
    
    # Extract proportion of A mode (1++,1--,2+-,2-+)
    A_FR_mode=$(echo "$infer_result" | grep "1++,1--,2+-,2-+" | awk '{print $NF}')
    
    # Extract proportion of B mode (1+-,1-+,2++,2--)
    B_RF_mode=$(echo "$infer_result" | grep "1+-,1-+,2++,2--" | awk '{print $NF}')
    
    # Calculate A-B difference (retain 4 decimal places)
    A_B_diff=$(echo "$A_FR_mode - $B_RF_mode" | bc | awk '{printf "%.4f", $0}')
    
    #######################################################################
    # 5. Determine strand type and recommended parameters according to rules
    #######################################################################
    if (( $(echo "$A_FR_mode > 0.7" | bc -l) )); then
        strand_type="FR-strand-specific"
        recommended_param="--fr"
    elif (( $(echo "$A_FR_mode < 0.3" | bc -l) )); then
        strand_type="RF-strand-specific"
        recommended_param="--rf"
    else
        # Intermediate range: check if absolute value of A-B difference is ¡Ý0.3 (30%)
        abs_diff=$(echo "if($A_B_diff < 0) -$A_B_diff else $A_B_diff" | bc)
        if (( $(echo "$abs_diff >= 0.3" | bc -l) )); then
            if (( $(echo "$A_FR_mode > $B_RF_mode" | bc -l) )); then
                strand_type="Weak FR-strand-specific"
                recommended_param="--fr"
            else
                strand_type="Weak RF-strand-specific"
                recommended_param="--rf"
            fi
        else
            strand_type="Non-strand-specific"
            recommended_param="None"
        fi
    fi
    
    #######################################################################
    # 6. Output results to CSV
    #######################################################################
    echo "$sample,$fraction_failed,$A_FR_mode,$B_RF_mode,$A_B_diff,$strand_type,$recommended_param" >> $OUTPUT_CSV
    
    #######################################################################
    # 7. Clean up temporary files (to avoid space occupation)
    #######################################################################
    rm -f $temp_fastq1 $temp_fastq2 $temp_bam
    
    echo "Sample $sample processing completed! Strand type: $strand_type, Recommended parameter: $recommended_param"
    echo "========================================"
    echo ""
done

###########################################################################
# Step 4: Processing completion prompt
###########################################################################
echo "All samples processed!"
echo "Result summary file: $(pwd)/$OUTPUT_CSV"
echo "Table column descriptions:"
echo "1. Sample_Name: Sample name"
echo "2. Fraction_Failed: Proportion of reads that could not be determined (smaller is better)"
echo "3. A_FR_mode: Proportion of FR mode (1++,1--,2+-,2-+)"
echo "4. B_RF_mode: Proportion of RF mode (1+-,1-+,2++,2--)"
echo "5. A-B_diff: A-B difference (positive value favors FR, negative value favors RF)"
echo "6. Strandness_Type: Strand type (FR/RF/Weak strand/Non-strand)"
echo "7. Recommended_StringTie_Param: Recommended StringTie parameter"


end_time=$(date +"%Y-%m-%d %H:%M:%S")
final_count=$(ls -l $tab_output|wc -l)
mail_content="? Completed all identification for Arabidopsis ssRNA-seq\n
? Start time: $start_time\n
? End time: $end_time\n
? Arabidopsis ssRNA-seq analysis completed, 184 materials processed\n
? Output file: All results are saved in $(pwd)/$OUTPUT_CSV \n
? Analysis log: batch_strandness_check.sh.log
? Note: This email is sent by msmtp+mailx in WSL, Chinese characters display normally¡«"

# Send email (underlying msmtp automatically completes SMTP authentication, no syntax errors)
echo -e "$mail_content" | mailx -s "¡¾Bioinformatics Task Success¡¿Arabidopsis ssRNA-seq Analysis Completed" "$receiver"

echo "=== ? Analysis pipeline ended! Results have been notified to $receiver via email ==="