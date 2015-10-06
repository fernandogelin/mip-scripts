
#Variant Calling
java -Xmx100G -jar /data2/fgelin/software/GenomeAnalysisTKv3.1.jar \
			  -nt 10 -nct 4 \
			  -R /data2/fgelin/resources/ucsc.hg19.fasta \
			  -T UnifiedGenotyper \
			  -o /data2/fgelin/scz_mip_sequences/variant_call/scz_20150922.vcf \
			  -L /data2/fgelin/scz_mip_sequences/target_from_mip.bed \
			  -I bam_files_004.list \
			  -I bam_files_005.list \
			  --output_mode EMIT_VARIANTS_ONLY \
			  -stand_call_conf 50.0 \
			  -stand_emit_conf 10.0 \
			  -glm BOTH \
			  -dcov 1000 \
			  --annotation AlleleBalance \
			  --annotation FisherStrand \
			  --annotation VariantType \
			  --annotation Coverage \
			  --annotation BaseCounts \
			  --annotation DepthPerAlleleBySample \
			  --annotation HomopolymerRun \
			  --annotation HaplotypeScore \
			  --annotation HardyWeinberg \
			  --annotation InbreedingCoeff \
			  --annotation LowMQ \
			  --annotation MappingQualityRankSumTest \
			  --annotation MappingQualityZero \
			  --annotation QualByDepth \
			  --read_filter MappingQuality \
			  --annotation RMSMappingQuality \
			  --annotateNDA
wait

# GATK VariantFiltration

java -Xmx50g -jar /data2/fgelin/software/GenomeAnalysisTKv3.1.jar \
 			 -T VariantFiltration \
 			 -R /data2/fgelin/resources/ucsc.hg19.fasta \
			 --variant /data2/fgelin/scz_mip_sequences/variant_call/scz_20150922.vcf \
			 -o /data2/fgelin/scz_mip_sequences/variant_call/scz_20150922_filtered.vcf \
			 --filterExpression "QD < 5.0" \
			 --filterName "QDFilter" \
			 --filterExpression "QUAL <= 30.0" \
			 --filterName "QUALFilter" \
			 --clusterSize 3 \
			 --baq OFF \
			 -baqGOP 40 \
			 --defaultBaseQualities 1 \
			 --filterExpression "MQ < 30.00" \
			 --filterName "MQ" \
			 --filterExpression "FS > 60.000" \
			 --filterName "FS" \
			 --filterExpression "HRun > 5.0" \
			 --filterName "HRunFilter" \
			 --filterExpression "ABHet > 0.75" \
			 --filterName "ABFilter" \
			 --filterExpression "SB > -10.0 " \
			 --filterName "StrandBias"
wait
# VariantRecalibrator - SNPs.
# PDF will be generated only if R is installed, otherwise only R scripts will be generated.

java -Xmx50g -jar /data2/fgelin/software/GenomeAnalysisTKv3.1.jar  \
	 -T VariantRecalibrator \
	 -R /data2/fgelin/resources/ucsc.hg19.fasta \
     -input /data2/fgelin/scz_mip_sequences/variant_call/scz_20150922_filtered.vcf \
	 -resource:hapmap,known=false,training=true,truth=true,prior=15.0 /data2/fgelin/resources/broad_bundle_hg19_v2.8/hapmap_3.3.hg19.sites.vcf.gz \
	 -resource:omni,known=false,training=true,truth=false,prior=12.0 /data2/fgelin/resources/broad_bundle_hg19_v2.8/1000G_omni2.5.hg19.sites.vcf.gz \
	 -resource:dbsnp,known=true,training=false,truth=false,prior=6.0 /data2/fgelin/resources/broad_bundle_hg19_v2.8/dbsnp_138.hg19.vcf.gz \
	 -an QD -an HaplotypeScore -an MQRankSum -an ReadPosRankSum -an FS -an MQ \
	 -mode SNP \
	 -recalFile /data2/fgelin/scz_mip_sequences/variant_call/temp/scz_20150922_filtered.vcf.snp.recal \
	 -tranchesFile /data2/fgelin/scz_mip_sequences/variant_call/temp/scz_20150922_filtered.vcf.snp.tranches \
	 -rscriptFile /data2/fgelin/scz_mip_sequences/variant_call/temp/scz_20150922_filtered.vcf.snp.plots.R
wait
# ApplyRecalibration - SNPs

java -Xmx50g -jar /data2/fgelin/software/GenomeAnalysisTKv3.1.jar \
	 -T ApplyRecalibration \
	 -R /data2/fgelin/resources/ucsc.hg19.fasta \
	 -input /data2/fgelin/scz_mip_sequences/variant_call/scz_20150922_filtered.vcf \
	 --ts_filter_level 99.0 \
	 -tranchesFile /data2/fgelin/scz_mip_sequences/variant_call/temp/scz_20150922_filtered.vcf.snp.tranches \
	 -recalFile /data2/fgelin/scz_mip_sequences/variant_call/temp/scz_20150922_filtered.vcf.snp.recal \
	 -mode SNP \
	 -o /data2/fgelin/scz_mip_sequences/variant_call/scz_20150922_filtered_recal_snp.vcf
wait
# VariantRecalibrator - INDELS 

java -Xmx50g -jar /data2/fgelin/software/GenomeAnalysisTKv3.1.jar \
	 -T VariantRecalibrator \
	 -R /data2/fgelin/resources/ucsc.hg19.fasta \
	 -input /data2/fgelin/scz_mip_sequences/variant_call/scz_20150922_filtered_recal_snp.vcf  \
	 -resource:mills,known=false,training=true,truth=true,prior=15.0 /data2/fgelin/resources/broad_bundle_hg19_v2.8/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf.gz \
	 -an QD -an MQRankSum -an ReadPosRankSum -an FS -an MQ \
	 -mode  INDEL \
	 -recalFile /data2/fgelin/scz_mip_sequences/variant_call/temp/scz_20150922_filtered.vcf.snp.indel.recal \
	 -tranchesFile /data2/fgelin/scz_mip_sequences/variant_call/temp/scz_20150922_filtered.vcf.snp.indel.tranches \
	 -rscriptFile /data2/fgelin/scz_mip_sequences/variant_call/temp/scz_20150922_filtered.vcf.snp.indel.plots.R
wait
 # ApplyRecalibration - INDELS

java -Xmx50g -jar software/GenomeAnalysisTK.jar \
	 -T ApplyRecalibration \
	 -R /data2/fgelin/resources/ucsc.hg19.fasta \
	 -input /data2/fgelin/scz_mip_sequences/variant_call/scz_20150922_filtered_recal_snp.vcf  \
	 --ts_filter_level 99.0 \
     -recalFile /data2/fgelin/scz_mip_sequences/variant_call/temp/scz_20150922_filtered.vcf.snp.indel.recal \
	 -tranchesFile /data2/fgelin/scz_mip_sequences/variant_call/temp/scz_20150922_filtered.vcf.snp.indel.tranches \
	 -mode INDEL \
	 -o /data2/fgelin/scz_mip_sequences/variant_call/scz_20150922_filtered_recal_snp_indel.vcf