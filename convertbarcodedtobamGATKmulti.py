
## convert all barcoded samfiles (Barcodexyz.sam) into bam suitabel for GATK analysis

import pysam, string, sys, os, subprocess, time, threading

barcode = sys.argv[1] # barcode ident: e.g. Barcode
GATKdir = sys.argv[2] # directory of GATK
hgreference = sys.argv[3] # position of human genome reference fasta
picarddir = sys.argv[4] # dir of picardtools
known_snp_dir = sys.argv[5] # position of snp-vcf: needs to be produced with the same reference as the bam-file
lane = sys.argv[6] #illumina lane identifier, e.g. hiseq1, hiseq2
working_dir = sys.argv[7] # directory with sorted bam files

GATK = os.path.join(GATKdir, 'GenomeAnalysisTKv3.1.jar')


Barcode = 0
multithread = 0

lock = threading.Lock()

class CountThread(threading.Thread):
    def run(self):
        lock.acquire()
        print 'thread running'
        global Barcode
        Barcode = Barcode + 1
        global bctransglob
        bctransglob = "%03d" % Barcode
        bctrans = threading.local
        bctrans = bctransglob
        checkforfile = threading.local
        checkforfile = os.path.isfile(str(barcode) + str(bctrans) + '.sam')
        Barcodefile = threading.local
        Barcodefile = str(barcode) + str(bctrans) + '.sam'
        lock.release()
        print 'thread still running'
        if checkforfile is True:
            print 'True'

            subprocess.call(["java", "-Xmx4G", "-jar", picarddir + "AddOrReplaceReadGroups.jar", "I=" + working_dir + str(barcode) + str(bctrans) + '.sam', "O=" + working_dir + str(barcode) + str(bctrans) + '_regrouped.sam', "RGLB=" + lane, "RGPL=illumina", "RGPU=" + str(bctrans), "RGSM=" + str(bctrans)])
            subprocess.call(["java", "-Xmx4G", "-jar", picarddir + "SamFormatConverter.jar", "I=" + working_dir + str(barcode) + str(bctrans) + '_regrouped' + '.sam', "O=" + working_dir + str(barcode) + str(bctrans) + '_regrouped.bam', "VALIDATION_STRINGENCY=LENIENT"])
            subprocess.call(["java", "-Xmx4G", "-jar", picarddir + "ReorderSam.jar", "I=" + working_dir +  str(barcode) + str(bctrans) + '_regrouped.bam', "O=" + working_dir + str(barcode) + str(bctrans) + '_reordered.bam', "REFERENCE=", hgreference])
            
            subprocess.call(["java", "-Xmx4G", "-jar", picarddir + "SortSam.jar", "I=" + working_dir + str(barcode) + str(bctrans) + '_reordered.bam', "O=" + working_dir + str(barcode) + str(bctrans) + '_sorted.bam', "SORT_ORDER=coordinate"])
            subprocess.call(["java", "-Xmx4G", "-jar", picarddir + "BuildBamIndex.jar", "I=" + working_dir + str(barcode) + str(bctrans) + '_sorted.bam', "O=" + working_dir + str(barcode) + str(bctrans) + '_sorted.bam.bai'])
            
            subprocess.call(["java", "-Xmx4G", "-jar", GATK, "-T", 'IndelRealigner', "-R", hgreference, "-known", known_snp_dir + "Mills_and_1000G_gold_standard.indels.hg19.sites.vcf", "-known", known_snp_dir + "1000G_phase1.indels.hg19.sites.vcf", "-targetIntervals", working_dir + 'output.intervals', "-I",working_dir + str(barcode) + str(bctrans) + '_sorted.bam',  "-o", working_dir +  str(barcode) + str(bctrans) + '_ind_realigned.bam'])
            subprocess.call(["java", "-Xmx4G", "-jar", GATK, "-T", 'BaseRecalibrator', "-R", hgreference, "-knownSites",  known_snp_dir + "Mills_and_1000G_gold_standard.indels.hg19.sites.vcf", "-knownSites", known_snp_dir + "1000G_phase1.indels.hg19.sites.vcf", "-I",working_dir +  str(barcode) + str(bctrans) + '_ind_realigned.bam', "-o", working_dir + str(barcode) + str(bctrans) + '_recal_data.table'])
            subprocess.call(["java", "-Xmx4G", "-jar", GATK, "-T", 'PrintReads', "-R", hgreference, "-I", working_dir + str(barcode) + str(bctrans) + '_ind_realigned.bam', "-BQSR", working_dir + str(barcode) + str(bctrans) + '_recal_data.table', "-o",working_dir+ str(barcode) + str(bctrans) + '_forGATK.bam'])
            
                             
        print 'still running'
        lock.acquire()
        print 'locked'
        global multithread
        multithread = multithread - 1
        lock.release()
        print 'thread ended'
        
#subprocess.call(["java", "-Xmx1g", "-jar", GATK, "-T", 'RealignerTargetCreator',"-R", hgreference, "-known", known_snp, "-o", working_dir + 'output.intervals'])    

multithread = 0
start = time.time()
for i in range (960):
    if multithread >= 10:
        while multithread >= 10:
            print 'sleeping'
            time.sleep(2)
    if multithread < 10:
        multithread = multithread + 1
        print 'starting thread'
        a = CountThread()
        a.start()

        

for a in threading.enumerate():
    if a is not threading.currentThread():
        a.join()

end = time.time()
print end - start
        
    
    
