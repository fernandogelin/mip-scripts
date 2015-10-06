# local computer
#macqiime

# fgelin_scz_004
split_libraries_fastq.py -b HC2FYBCXXs_1_2_merged.fastq.gz -i HC2FYBCXXs_1_1_merged.fastq.gz -m barcode-id-file.txt -o s_1_1 --store_demultiplexed_fastq -n 100 --rev_comp_barcode --barcode_type 10 --max_barcode_errors 3 --retain_unassigned_reads -p 0 -q 0 -r 100
split_libraries_fastq.py -b HC2FYBCXXs_1_2_merged.fastq.gz -i HC2FYBCXXs_1_3_merged.fastq.gz -m barcode-id-file.txt -o s_1_3 --store_demultiplexed_fastq -n 100 --rev_comp_barcode --barcode_type 10 --max_barcode_errors 3 --retain_unassigned_reads -p 0 -q 0 -r 100

# fgelin_scz_005
split_libraries_fastq.py -b HC2FYBCXXs_2_2_merged.fastq.gz -i HC2FYBCXXs_2_1_merged.fastq.gz -m barcode-id-file.txt -o s_2_1 --store_demultiplexed_fastq -n 100 --rev_comp_barcode --barcode_type 10 --max_barcode_errors 3 --retain_unassigned_reads -p 0 -q 0 -r 100
split_libraries_fastq.py -b HC2FYBCXXs_2_2_merged.fastq.gz -i HC2FYBCXXs_2_3_merged.fastq.gz -m barcode-id-file.txt -o s_2_3 --store_demultiplexed_fastq -n 100 --rev_comp_barcode --barcode_type 10 --max_barcode_errors 3 --retain_unassigned_reads -p 0 -q 0 -r 100


# server
# run script from fgelin directory
cd /data2/fgelin/scz_mip_sequences/$1
mkdir intermediate_files
mkdir coverage
MIP pipeline

# Align to reference
/data1/jan/programs/bwa-0.7.4/bwa mem /data2/fgelin/resources/hg19_bwa_indexed/hg19.fasta -t 30 -P -R "@RG\tID:fgelin_scz\tSM:HiSeq\tPL:ILLUMINA" s_$2_1/seqs.fastq s_$2_3/seqs.fastq > intermediate_files/$1.sam 
wait

#Sort, Index and Check coverage
samtools view -bS -h intermediate_files/$1.sam | samtools sort - intermediate_files/$1
wait
samtools index intermediate_files/$1.bam
wait

# Coverage for original bam file
/usr/local/bin/python2.7 /data2/fgelin/scz_mip_sequences/scripts/lowbasesamtoolsmultioptimise.py /data2/fgelin/scz_mip_sequences/mip_4.picked_mips_corrected.txt intermediate_files/$1.bam coverage/coverage_$1.txt
wait
mkdir barcode-sam
cd barcode-sam
#Split bam file based on barcodes
/usr/local/bin/python2.7 ../../scripts/sortsambarcode.py ../intermediate_files/$1.sam Barcode 
wait
/usr/local/bin/python2.7 ../../scripts/extract-mips.py ../../mip_4.picked_mips_corrected.txt Barcode 4 xyz.sam ../barcode-sam/
wait
/usr/local/bin/python2.7 ../../scripts/extract-test.py ../../mip_4.picked_mips_corrected.txt Barcode 4 ../intermediate_files/$1.sam ../intermediate_files/$1_nonduplicate.sam ../barcode-sam/
wait
samtools view -bS -h ../intermediate_files/$1_nonduplicate.sam | samtools sort - ../intermediate_files/$1_nonduplicate
wait
samtools index ../intermediate_files/$1_nonduplicate.bam
wait
cd ..
#Check for coverage again
/usr/local/bin/python2.7 ../scripts/lowbasesamtoolsmultioptimise.py ../mip_4.picked_mips_corrected.txt intermediate_files/$1_nonduplicate.bam coverage/coverage_$1_nonduplicate.txt
wait
/usr/local/bin/python2.7 ../scripts/samextract.py ../mip_4.picked_mips_corrected.txt intermediate_files/$1_nonduplicate.bam intermediate_files/$1_nonduplicate.fastq intermediate_files/$1_nonduplicate.txt intermediate_files/$1_nonduplicate_junk.fastq 4 56
wait
fastx_clipper -Q33 -d 200 -l 7 -i intermediate_files/$1_nonduplicate.fastq -o intermediate_files/$1_nonduplicate_clip.fastq
wait
/data1/jan/programs/bwa-0.7.4/bwa aln -t 30 /data2/fgelin/resources/hg19_bwa_indexed/hg19.fasta intermediate_files/$1_nonduplicate_clip.fastq > intermediate_files/$1_nonduplicate_clip.sai
wait
/data1/jan/programs/bwa-0.7.4/bwa samse /data2/fgelin/resources/hg19_bwa_indexed/hg19.fasta intermediate_files/$1_nonduplicate_clip.sai intermediate_files/$1_nonduplicate_clip.fastq > intermediate_files/$1_nonduplicate_clip.sam
wait

rm barcode-sam/*Barcode*sam

mkdir barcode-sam-2
cd barcode-sam-2
/usr/local/bin/python2.7 ../../scripts/sortsambarcode.py ../intermediate_files/$1_nonduplicate_clip.sam Barcode &
wait
/usr/local/bin/python2.7 ../../scripts/convertbarcodedtobamGATKmulti.py Barcode /data2/fgelin/software/ /data2/fgelin/resources/ucsc.hg19.fasta /data2/fgelin/software/picard-tools-1/picard-tools-1.114/ /data2/fgelin/resources/ HiSeq /data2/fgelin/scz_mip_sequences/$1/barcode-sam-2/
wait


