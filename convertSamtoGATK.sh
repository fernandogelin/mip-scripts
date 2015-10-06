#java -Xmx20g -jar /data2/fgelin/software/GenomeAnalysisTKv3.1.jar -T RealignerTargetCreator -R /data2/fgelin/resources/ucsc.hg19.fasta -known /data2/fgelin/resources/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf -known /data2/fgelin/resources/1000G_phase1.indels.hg19.sites.vcf -o output.intervals

files=/data2/fgelin/scz_mip_sequences/$1/barcode-sam-2/Barcode*.sam

for f in $files
do

	java -Xmx4G -jar /data2/fgelin/software/picard-tools-1/picard-tools-1.114/AddOrReplaceReadGroups.jar I= $f O= $f.regrouped.sam RGLB=HiSeq1 RGPL=illumina RGPU=$f RGSM=$f
	wait
	java -Xmx4G -jar /data2/fgelin/software/picard-tools-1/picard-tools-1.114/SamFormatConverter.jar I= $f.regrouped.sam O= $f.regrouped.bam VALIDATION_STRINGENCY=LENIENT
	wait
	java -Xmx4G -jar /data2/fgelin/software/picard-tools-1/picard-tools-1.114/ReorderSam.jar I= $f.regrouped.bam O= $f.reordered.bam REFERENCE= data2/fgelin/resources/ucsc.hg19.fasta
	wait
	java -Xmx4G -jar /data2/fgelin/software/picard-tools-1/picard-tools-1.114/SortSam.jar I= $f.reordered.bam O= $f.sorted.bam SORT_ORDER=coordinate
	wait
	java -Xmx4G -jar /data2/fgelin/software/picard-tools-1/picard-tools-1.114/BuildBamIndex.jar INPUT= $f.sorted.bam OUTPUT= $f.sorted.bam.bai
	wait
	java -Xmx4G -jar /data2/fgelin/software/GenomeAnalysisTKv3.1.jar -T IndelRealigner -R /data2/fgelin/resources/ucsc.hg19.fasta -known /data2/fgelin/resources/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf -known /data2/fgelin/resources/1000G_phase1.indels.hg19.sites.vcf -targetIntervals /data2/fgelin/scz_mip_sequences/$1/barcode-sam-2/output.intervals -I $f.sorted.bam  -o $f.ind_realigned.bam
	wait
	java -Xmx4G -jar /data2/fgelin/software/GenomeAnalysisTKv3.1.jar -T BaseRecalibrator -R /data2/fgelin/resources/ucsc.hg19.fasta -knownSites /data2/fgelin/resources/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf -knownSites /data2/fgelin/resources/1000G_phase1.indels.hg19.sites.vcf -I $f.ind_realigned.bam -o $f.recal_data.table
	wait
	java -Xmx4G -jar /data2/fgelin/software/GenomeAnalysisTKv3.1.jar -T PrintReads -R /data2/fgelin/resources/ucsc.hg19.fasta -I $f.ind_realigned.bam -BQSR $f.recal_data.table -o $f.forGATK.bam
	wait

done


