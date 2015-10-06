import string, sys, os, subprocess, glob, re

input1 = sys.argv[1] # sample/subject-ID + barcode
input2 = sys.argv[2] # input directory
input3 = sys.argv[3] # output dir
input4 = sys.argv[4] # picard directory
input5 = sys.argv[5] # Hiseq lane No


key = open(input1, 'r')

for line in key:
	split = line.split()
	Barcode = int(split[1])
	name = split[0]
	bctrans = "%03d" % Barcode
	subprocess.call(["java", "-jar", input4 + "AddOrReplaceReadGroups.jar", "I=" + input2 + 'Barcode' + str(bctrans) + '_forGATK' + '.bam', "O=" + input3 + 'sample' + str(name) + '_forGATK' + '.bam', "RGLB=" + input5, "RGPL=illumina", "RGPU=" + str(name), "RGSM=" + str(name)])
	subprocess.call(["java", "-jar", input4 + "BuildBamIndex.jar", "INPUT=" + input3 + 'sample' + str(name) + '_forGATK' + '.bam', "OUTPUT=" + input3 + 'sample' + str(name) + '_forGATK' + '.bai'])

key.close()

# /usr/local/bin/python2.7 scripts/barcodetosampleid.py fgelin_scz_004_barcode_id_key.txt fgelin_scz_004/barcode-sam-2/ fgelin_scz_004/forGATK/ ../software/picard-tools-1/picard-tools-1.114/ 1
# /usr/local/bin/python2.7 scripts/barcodetosampleid.py fgelin_scz_005_barcode_id_key.txt fgelin_scz_005/barcode-sam-2/ fgelin_scz_005/forGATK/ ../software/picard-tools-1/picard-tools-1.114/ 2