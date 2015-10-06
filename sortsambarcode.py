## split sam into barcode

import pysam, string, sys, os, subprocess, threading, time

samheader = open

input1 = sys.argv[1] # SAM-file
barcode = sys.argv[2] # barcode identifier


start = time.time()

f = open(input1, 'r')
counter = 0
header = 0
sort = ' '

for line in f:
        question = line.find('@SQ')
        question2 = line.find('@RG')
        if question > -1 or question2 > -1:
                filename = 'samheader'
                sort = open(str(filename) + '.txt', 'a')
                sort.write(line)
                sort.closed
        question = line.find(barcode)
        if question > -1:
                break

f.closed

sort = open ('dummyfile.txt', 'a')
f = open(input1, 'r')
for line in f:
        linenewfile = line
        question = line.find(barcode)
        if question > -1:
                sort.closed
                filename = line[:10]
                checkforfile = os.path.isfile(str(filename) + '.sam')
                if checkforfile is False:
                        samheader = open('samheader.txt', 'r')
                        sort = open(str(filename) + '.sam', 'a')
                        for line in samheader:
                                sort.write(line)
                        sort.write(linenewfile)
                        sort.closed
                        samheader.closed
                else:
                        sort = open(str(filename) + '.sam', 'a')
                        sort.write(line)
                        sort.closed
                

                #print line
#		header = 1
#	if question -1:
#		if header > 0:
#			sort.write(line)
os.remove('dummyfile.txt')
f.closed

lock = threading.Lock()		
counter = 1

class CountThread(threading.Thread):
        def run(self):
                lock.acquire()
                global counter
                global multithread
                bctrans = threading.local
                bctrans =  "%03d" % counter
                print bctrans
                Barcodenumber = threading.local
                Barcodenumber = str(barcode) + str(bctrans)
                checkforfile = threading.local
                checkforfile = os.path.isfile(Barcodenumber + '.sam')
                counter = counter + 1
                print Barcodenumber
                lock.release()
                if checkforfile is True:
                        print 'true'
                        subprocess.call(["samtools", "view", "-b", "-h", "-S", "-o", Barcodenumber + '.bam', Barcodenumber + '.sam' ])
                        subprocess.call(["samtools", "sort", Barcodenumber + '.bam', Barcodenumber + 'sorted'])
                        subprocess.call(["samtools", "index", Barcodenumber + 'sorted' + '.bam'])
                lock.acquire()
                multithread = multithread - 1
                lock.release()
                print 'thread ended'


threads = 30           
multithread = 0
#subprocess.call(["ulimit", "-u", "2048"], shell=True)

for i in range (960): 
    if multithread >= threads:
        while multithread >= threads:
            print 'sleeping'
            time.sleep(2)
    if multithread < threads:
#	time.sleep(2)
        multithread = multithread + 1
        print 'starting thread'
        a = CountThread()
        a.start()
        

for a in threading.enumerate():
    if a is not threading.currentThread():
        a.join()

end = time.time()
print end - start
