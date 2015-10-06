import pysam, string, sys, os, subprocess, glob, threading, time

input1 = sys.argv[1] # MIP file
barcode = sys.argv[2] # Barcode
input3 = sys.argv[3] # Stringency
input4 = sys.argv[4] # samfile to clean
input5 = sys.argv[5] # working directory

stringency = int(input3)

#h = open(input1, 'r')
t = 0

z = 0
Barcode = 1

start = time.time()
for i in range(960):
    bctrans = "%03d" % Barcode
    Barcode = Barcode + 1
    Barcodenumber = str(barcode) + str(bctrans)
    print Barcodenumber
    checkforfile = os.path.isfile(input5 + Barcodenumber + 'sorted' + '.bam')
    print checkforfile
    if checkforfile is True:
        os.mkdir(input5 + Barcodenumber)

        h = open(input1, 'r')
        for line in h:
            stri = line.split()
            mipident = str(stri[0] + '.fastq')
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
            filename = os.path.join(input5, Barcodenumber, mipident)
            output = open(filename, 'a+')
            samfile = pysam.Samfile(input5 + Barcodenumber + 'sorted' + '.bam', "rb" )
            iter = samfile.fetch( region= (coordinate) )
            for AlignedRead in iter:
                if AlignedRead.aend == None: aend = 0
                else: aend = int(AlignedRead.aend)

                read1 = AlignedRead.qname.find('/1_')

                ## Everything is right; start of miparm and alignment match; most probably forward read 1
                if strand == '+' and (stringency * -1) <= extprobstartint - AlignedRead.pos <= stringency and read1 == -1:
                    output.write('@' + AlignedRead.qname + '_' + 'Question1_' + str(stri[0]))
                    output.write('\n')
                    output.write(AlignedRead.seq[:5])
                    output.write('\n')
                    output.write('+' + AlignedRead.qname + '_' + 'Question1_' + str(stri[0]))
                    output.write('\n')
                    output.write(AlignedRead.qual[:5])
                    output.write('\n')
                    z = z + 1
                    
        # stop of read and stop of lig-arm of alignment match  
                elif strand == '-' and (stringency * -1) <= extprobstopint - aend <= stringency and read1 == -1:
                    begin = scanstopint - AlignedRead.pos - 75
                    if scanstopint - AlignedRead.pos - 75 <= 0: begin = 0
                
                    output.write('@' + AlignedRead.qname + '_' + 'Question5_' + str(stri[0]) + '_' + str(aend))
                    output.write('\n')
                    output.write(AlignedRead.seq[-5:])
                    output.write('\n')
                    output.write('+' + AlignedRead.qname + '_' + 'Question5_' + str(stri[0]) + '_' + str(aend))
                    output.write('\n')
                    output.write(AlignedRead.qual[-5:])
                    output.write('\n')
                    z = z + 1
        

        
            samfile.close()
            output.closed
            print filename

Barcode2 = 1
lock = threading.Lock()

            
class CountThread(threading.Thread):
    def run(self):
        lock.acquire()
        global Barcode2
        global bctrans
        bctrans = "%03d" % Barcode2
        global Barcode
        Barcode2 = Barcode2 + 1
        Barcodenumber = threading.local
        Barcodenumber = str(barcode) + str(bctrans)
        lock.release()
        print Barcodenumber
        checkforfile = os.path.isfile(input5 + Barcodenumber + 'sorted' + '.bam')
        print checkforfile
        if checkforfile is True:
            h = threading.local
            h = open(input1, 'r')
            for line in h:
                stri = threading.local
                stri = line.split()
                mipident = threading.local
                mipident = str(stri[0] + '.fastq')
                filename = threading.local
                filename = os.path.join(input5, Barcodenumber, mipident)
                subprocess.call(["perl", "/data2/fgelin/software/prinseq-lite-0.20.4/prinseq-lite.pl", "-fastq", filename, "-derep", "1", "-derep_min", "2"])
                print filename

            h.closed
        lock.acquire()
        global multithread
        multithread = multithread - 1
        lock.release()

            
threads = 40           
multithread = 0
#subprocess.call(["ulimit", "-u", "2048"], shell=True)

for i in range (960): 
    if multithread >= threads:
        while multithread >= threads:
            print 'sleeping'
            time.sleep(5)
    if multithread < threads:
#	time.sleep(2)
        multithread = multithread + 1
        print 'starting thread'
        a = CountThread()
        a.start()
        time.sleep(5)
        

for a in threading.enumerate():
    if a is not threading.currentThread():
        a.join()

end = time.time()
print end - start    
