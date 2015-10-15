source("https://bioconductor.org/biocLite.R")
biocLite("TxDb.Hsapiens.UCSC.hg19")

library(VariantAnnotation)
library(ggplot2)
library(reshape2)
library(dplyr)
library(data.table)
library(ggvis)
library(rCharts)
library(AnnotationHub)
library(BSgenome.Hsapiens.UCSC.hg19)
library(SIFT.Hsapiens.dbSNP137)
library(TxDb.Hsapiens.UCSC.hg19)

genes = c("MARCH7","RPN1", "EPHA5", "WDR4", "WDR7", "CSMD2", "ZNF665")
setwd("/Users/fernandogelin/Desktop/scz_targeted/variant_call/")
vcf <- readVcf("/Users/fernandogelin/Desktop/scz_targeted/variant_call/swedish_subset_mip_genes.hg19_multianno_cc.vcf", "hg19")

for (gene in genes) {
     print(gene)
     assign(gene, vcf[unlist(info(vcf)$Gene.refGene) == gene])
     var = names(rowRanges(get(gene)))
     chr = as.character(seqnames(get(gene)))
     pos = start(get(gene))
     function_ = info(get(gene))$SNPEFF_EFFECT
     gene = info(get(gene))$SNPEFF_GENE_NAME 
     oneK = info(get(gene))$"1000g2014oct_all"
     aa_change = info(get(gene))$SNPEFF_AMINO_ACID_CHANGE
     funct = unlist(info(get(gene))$ExonicFunc.refGene)
     impact = info(get(gene))$SNPEFF_IMPACT
     p_all = info(get(gene))$CC_ALL
     ref = as.character(rowRanges(get(gene))$REF)
     alt = as.character(unlist(rowRanges(get(gene))$ALT))
     cases_hom = c()
     cases_het = c()
     cases_tot = c()
     controls_hom = c()
     controls_het = c()
     controls_tot = c()
     for (i in 1:dim(info(get(gene)))[1]) {
          cases_hom = append(cases_hom, info(get(gene))$Cases[[i]][1])
          cases_het = append(cases_het, info(get(gene))$Cases[[i]][2])
          cases_tot = append(cases_tot, info(get(gene))$Cases[[i]][3])
          controls_hom = append(controls_hom, info(get(gene))$Controls[[i]][1])
          controls_het = append(controls_het, info(get(gene))$Controls[[i]][2])
          controls_tot = append(controls_tot, info(get(gene))$Controls[[i]][3])
     }
     assign(paste(gene, "table", sep="_"), 
            data.table(var,chr,pos,ref,alt,gene,oneK,aa_change,function_,impact,cases_hom,cases_het,cases_tot,controls_hom,controls_het,controls_tot,p_all))
     
     assign(paste(gene, "table", sep="_"), filter(get(paste(gene, "table", sep="_")), !(funct %in% c("synonymous_SNV"))))
     assign(paste(gene, "table", sep="_"), filter(get(paste(gene, "table", sep="_")), !(function_ %in% c("INTRON", "UPSTREAM"))))
}

write.csv(MARCH7_table, "MARCH7_table.csv")
write.csv(EPHA5_table, "EPHA5_table.csv")
write.csv(RPN1_table, "RPN1_table.csv")
write.csv(WDR4_table, "WDR4_table.csv")
write.csv(WDR7_table, "WDR7_table.csv")
write.csv(CSMD2_table, "CSMD2_table.csv")
write.csv(ZNF665_table, "ZNF665_table.csv")



