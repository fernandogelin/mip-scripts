
# 4 Load into PSEQ
# Create new project
pseq scz_combined new-project --resources hg19/
# load VCF
pseq scz_combined load-vcf --vcf annotated_gene_subset-2.vcf
# load phenotype file
pseq scz_combined load-pheno --file scz.phe
# Run gene based association tests (frequencies x<0.01,0.01<x<=0.05, x<=0.05)
pseq scz_combined assoc --phenotype scz --mask loc.group=refseq mac=1-50 any.filter.ex meta.req=DP:ge:8,'1000g2014oct_all':lt:0.01 include="ExonicFunc.refGene == 'stopgain' ||  ExonicFunc.refGene == 'stoploss' || ExonicFunc.refGene == 'frameshift_deletion' || ExonicFunc.refGene == 'frameshift_insertion' || ExonicFunc.refGene == 'nonsynonymous_SNV'" --tests burden uniq vt calpha sumstat > assoc_tests_combined/assoc_tests_combined_mac100_le1.txt &
pseq scz_combined assoc --phenotype scz --mask loc.group=refseq mac=1-50 any.filter.ex meta.req=DP:ge:8,'1000g2014oct_all':ge:0.01,'1000g2014oct_all':le:0.05 include="ExonicFunc.refGene == 'stopgain' ||  ExonicFunc.refGene == 'stoploss' || ExonicFunc.refGene == 'frameshift_deletion' || ExonicFunc.refGene == 'frameshift_insertion' || ExonicFunc.refGene == 'nonsynonymous_SNV'" --tests burden uniq vt calpha sumstat > assoc_tests_combined/assoc_tests_combined_mac100_gt1_le5.txt &
pseq scz_combined assoc --phenotype scz --mask loc.group=refseq mac=1-50 any.filter.ex meta.req=DP:ge:8,'1000g2014oct_all':le:0.05 include="ExonicFunc.refGene == 'stopgain' ||  ExonicFunc.refGene == 'stoploss' || ExonicFunc.refGene == 'frameshift_deletion' || ExonicFunc.refGene == 'frameshift_insertion' || ExonicFunc.refGene == 'nonsynonymous_SNV'" --tests burden uniq vt calpha sumstat > assoc_tests_combined/assoc_tests_combined_mac100_le5.txt &

pseq scz_combined assoc --phenotype scz --mask loc.group=refseq mac=1-50 any.filter.ex include="ExonicFunc.refGene == 'stopgain' ||  ExonicFunc.refGene == 'stoploss' || ExonicFunc.refGene == 'frameshift_deletion' || ExonicFunc.refGene == 'frameshift_insertion' || ExonicFunc.refGene == 'nonsynonymous_SNV'" --tests burden uniq vt calpha sumstat > assoc_tests_combined/assoc_tests_combined_mac100_all.txt &

# Run single locus association tests split by gene, set the positions and gene names
#!/bin/bash
# run pseq gene association tests filtering by 1000g frequencies
position=( chr11:124735305..124751370 \
chr19:53666552..53696619 \
chr3:128338813..128369719 \
chr2:160568968..160625094 \
chr8:87878676..88394955 \
chr7:148504464..148581441 \
chr11:88237744..88796846 \
chr5:176022803..176037131 \
chr15:77905366..78111866 \
chr1:33979599..34631443 \
chr18:54318616..54697036 \
chr21:44269336..44299699 \
chr22:39745954..39774394 \
chr3:152057487..152058779 \
chr4:66185281-66536213 \
chrX:146993469..147032647 \
chr6:111981535..112194655 \
chr11:67933186..67981239 \
chr2:143635195..143799885 \
chr7:130033612..130081051 \
chr16:9847262..10276611 \
chr2:166845670..166930149 \
chr19:51848465..51869571 \
chr5:168088738..168728133 \
chr3:182733006..182817375 \
chr16:699363..717829
 )

gene=( ROBO3 \
ZNF665 \
RPN1 \
MARCH7 \
CNBD1 \
EZH2 \
GRM5 \
GPRIN1 \
LINGO1 \
CSMD2 \
WDR7 \
WDR4 \
SYNGR1 \
TMEM14E \
EPHA5 \
FMR1 \
FYN \
SUV420H1 \
KYNU \¡
CEP41 \
GRIN2A \
SCN1A \
ETFB \
SLIT3 \
MCCC1 \
WDR90
 )

for ((i=0; i < ${#position[@]} && i < ${#gene[@]}; i++))
do
	echo "Processing sample $i..."
	pseq scz_combined v-assoc --phenotype scz --mask reg="${position[i]}" mac=1-100 any.filter.ex meta.req=DP:ge:8,'1000g2014oct_all':le:0.01 include="ExonicFunc.refGene == 'stopgain' ||  ExonicFunc.refGene == 'stoploss' || ExonicFunc.refGene == 'frameshift_deletion' || ExonicFunc.refGene == 'frameshift_insertion' || ExonicFunc.refGene == 'nonsynonymous_SNV'" --vmeta --show '1000g2014oct_all' SNPEFF_GENE_NAME 'ExonicFunc.refGene' SNPEFF_FUNCTIONAL_CLASS SNPEFF_IMPACT > assoc_tests_combined/le_1/"${gene[i]}"_le_1.txt

	pseq scz_combined v-assoc --phenotype scz --mask reg="${position[i]}" mac=1-100 any.filter.ex meta.req=DP:ge:8,'1000g2014oct_all':gt:0.01,'1000g2014oct_all':le:0.05 include="ExonicFunc.refGene == 'stopgain' ||  ExonicFunc.refGene == 'stoploss' || ExonicFunc.refGene == 'frameshift_deletion' || ExonicFunc.refGene == 'frameshift_insertion' || ExonicFunc.refGene == 'nonsynonymous_SNV'" --vmeta --show '1000g2014oct_all' SNPEFF_GENE_NAME 'ExonicFunc.refGene' SNPEFF_FUNCTIONAL_CLASS SNPEFF_IMPACT > assoc_tests_combined/gt1_le5/"${gene[i]}"_gt1le5.txt

	pseq scz_combined v-assoc --phenotype scz --mask reg="${position[i]}" mac=1-100 any.filter.ex meta.req=DP:ge:8,'1000g2014oct_all':le:0.05 include="ExonicFunc.refGene == 'stopgain' ||  ExonicFunc.refGene == 'stoploss' || ExonicFunc.refGene == 'frameshift_deletion' || ExonicFunc.refGene == 'frameshift_insertion' || ExonicFunc.refGene == 'nonsynonymous_SNV'" --vmeta --show '1000g2014oct_all' SNPEFF_GENE_NAME 'ExonicFunc.refGene' SNPEFF_FUNCTIONAL_CLASS SNPEFF_IMPACT > assoc_tests_combined/le_5/"${gene[i]}"_le_5.txt
	
	pseq scz_combined v-assoc --phenotype scz --mask reg="${position[i]}" mac=1-100 any.filter.ex meta.req=DP:ge:8 include="ExonicFunc.refGene == 'stopgain' ||  ExonicFunc.refGene == 'stoploss' || ExonicFunc.refGene == 'frameshift_deletion' || ExonicFunc.refGene == 'frameshift_insertion' || ExonicFunc.refGene == 'nonsynonymous_SNV'" --vmeta --show '1000g2014oct_all' SNPEFF_GENE_NAME 'ExonicFunc.refGene' SNPEFF_FUNCTIONAL_CLASS SNPEFF_IMPACT > assoc_tests_combined/all/"${gene[i]}"_all.txt
done


# Read gene files into ipython notebook, generate csv files.
