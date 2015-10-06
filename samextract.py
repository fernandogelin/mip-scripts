import pysam, string, sys

input1 = sys.argv[1] # MIP file
input2 = sys.argv[2] # cleave MIP arms from this samfile 
input3 = sys.argv[3] # output fastq
input4 = sys.argv[4] # reads statistics
input5 = sys.argv[5] # junk (e.g reads aligned outside target sites)
input6 = sys.argv[6] # stringency (reads can start/stop this many nucleotides near to their targeted start/stop sites, e.g. 2 or 4)
input7 = sys.argv[7] # how much should be trimed of each sequence? e.g. 56 (2 * 56 = 112)


input7 = int(input7)
h = open(input1, 'r')
t = 0
output = open(input3, 'a')
readcount = open(input4, 'a')
junk = open(input5, 'a')
stringency = int(input6)

z = 0

for line in h:
    stri = line.split()
    chromosome = stri[2]
    extprobstart = stri[3]
    extprobstartint = int(extprobstart)
    extprobstop = stri[4]
    extprobstopint = int(extprobstop)
    extarmlength = abs(extprobstartint - extprobstopint)
    ligprobstart = stri[7]
    ligprobstartint = int(ligprobstart)
    ligprobstop = stri[8]
    ligprobstopint = int(ligprobstop)
    ligarmlength = abs(ligprobstartint - ligprobstopint)
    scanstartint = int(stri[11])
    scanstopint = int(stri[12])
    strand = stri[17]
    coordinate = 'chr' + chromosome + ':' + stri[11] + '-' + stri[12]
    samfile = pysam.Samfile(input2, "rb" )
    iter = samfile.fetch( region= (coordinate) )
    for AlignedRead in iter:

        if AlignedRead.aend == None: aend = 0
        else: aend = int(AlignedRead.aend)

        read3 = AlignedRead.qname.find('/3_')
        read1 = AlignedRead.qname.find('/1_')
        
        ## Everything is right; start of miparm and alignment match (most probably forward read 1)
        if strand == '+' and (stringency * -1) <= extprobstartint - AlignedRead.pos <= stringency and read1 == -1:
            
            output.write('@' + AlignedRead.qname + '_' + 'Question1_' + str(stri[0]))
            output.write('\n')
            output.write(AlignedRead.query[(scanstartint - AlignedRead.pos - 1):(scanstartint - AlignedRead.pos + input7)])
            output.write('\n')
            output.write('+')
            output.write('\n')
            output.write(AlignedRead.qqual[(scanstartint - AlignedRead.pos - 1):(scanstartint - AlignedRead.pos + input7)])
            output.write('\n')
            z = z + 1
        # stop of read and stop of lig-arm of alignment match 
        elif strand == '+' and (stringency * -1) <= ligprobstopint - aend -1 <= stringency and read3 == -1:
                begin = scanstopint - AlignedRead.pos - input7
                if scanstopint - AlignedRead.pos - input7 <= 0: begin = 0
                
                output.write('@' + AlignedRead.qname + '_' + 'Question2_' + str(stri[0]) + '_' + str(aend))
                output.write('\n')
                output.write(AlignedRead.query[(begin):(scanstopint -  AlignedRead.pos)])
                output.write('\n')
                output.write('+')
                output.write('\n')
                output.write(AlignedRead.qqual[(begin):(scanstopint -  AlignedRead.pos)])
                output.write('\n')
                z = z + 1
                
        ## Everything is right; start of miparm and alignment match
        elif strand == '-' and (stringency * -1) <= ligprobstartint - AlignedRead.pos <= stringency and read3 == -1:
            output.write('@' + AlignedRead.qname + '_' + 'Question4_' + str(stri[0]))
            output.write('\n')
            output.write(AlignedRead.query[(scanstartint - AlignedRead.pos - 1):(scanstartint - AlignedRead.pos + input7)])
            output.write('\n')
            output.write('+')
            output.write('\n')
            output.write(AlignedRead.qqual[(scanstartint - AlignedRead.pos - 1):(scanstartint - AlignedRead.pos + input7)])
            output.write('\n')
            z = z + 1
        # stop of read and stop of lig-arm of alignment match  
        elif strand == '-' and (stringency * -1) <= extprobstopint - aend <= stringency and read1 == -1:
                begin = scanstopint - AlignedRead.pos - input7
                if scanstopint - AlignedRead.pos - input7 <= 0: begin = 0
                
                output.write('@' + AlignedRead.qname + '_' + 'Question5_' + str(stri[0]) + '_' + str(aend))
                output.write('\n')
                output.write(AlignedRead.query[(begin):(scanstopint -  AlignedRead.pos)])
                output.write('\n')
                output.write('+')
                output.write('\n')
                output.write(AlignedRead.qqual[(begin):(scanstopint -  AlignedRead.pos)])
                output.write('\n')
                z = z + 1


            
# everything aligned in position but not qualifying 
        else:
            junk.write('@' + AlignedRead.qname)
            junk.write('\n')
            junk.write(AlignedRead.query)
            junk.write('\n')
            junk.write('+')
            junk.write('\n')
            junk.write(AlignedRead.qqual)
            junk.write('\n')
            
            
    samfile.close()
    readcount.write('Reads at MIP ' + stri[0] + ' ' + str(z) + '\n')
    z = 0

readcount.closed    
h.closed
output.closed



