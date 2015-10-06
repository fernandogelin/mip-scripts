import pysam, string, sys, subprocess, threading, time 

input1 = sys.argv[1] # MIPs
input2 = sys.argv[2] # bamfile
input3 = sys.argv[3] # bascount.txt

g = open(input1, 'r')
#h = open(input2, 'r')
testsamtools = open('each_base.txt', 'a')

lock = threading.Lock()


class CountThread(threading.Thread):
        def run(self):
                lock.acquire()
                global count
                global coordinate2
                global check
                check2 = threading.local()      #this variable needs to be localized to this thread as no other thread should be able to change it before it gets submitted to samtools
                check2 = check
                check = check + 1
                coordinate = threading.local()  #this variable needs to be localized to this thread as no other thread should be able to change it before it gets submitted to samtools
                coordinate = "chr" + str(chromosome) + ':' + str(check2) + '-' + str(check2)
                coverage = threading.local()
                lock.release()
                coverage = subprocess.check_output(["samtools", "view", input2, "-c", coordinate])
                lock.acquire()  # lock this part: check whether there are less reads on this base as in one before in this MIP
#                testsamtools.write(coverage + ' ' + coordinate + '\n')
                if int(coverage) <= count and check2 <= scanstopint:
                        count = int(coverage)
                        coordinate2 = coordinate        # new lowest coverage found for this MIP so put new values into 'count' and 'coordinate' then release lock
#                        print 'lowest coverage at MIP' + stri[0] + ' ' + stri[19] + ' ' + 'chr' + coordinate2 + ' ' + str(count)
#                        time.sleep(1)
                lock.release()

start = time.time()
for line in g:
        count = 30000000
        stri = line.split()
        scanstartint = int(stri[11])
        scanstopint = int(stri[12])
        chromosome = stri[2]
        check = scanstartint
            
        while check <= scanstopint:
                it = threading.active_count()
#                print it
                if it < 16 and check <= scanstopint:
                        a = CountThread()
                        a.start()

        for a in threading.enumerate():
                if a is not threading.currentThread():
                        a.join()
                        print 'FINISHED'

        while a.isAlive() and a is not threading.currentThread():
                print 'Running!!!!!!!'
                time.sleep(2)
        print 'lowest coverage at MIP' + stri[0] + ' ' + stri[19] + ' ' + str(coordinate2) + ' ' + str(count)
    
        i = open(input3, 'a')        
        i.write('lowest coverage at MIP ' + stri[0] + ' ' + stri[19] + ' ' + str(coordinate2) + ' ' + str(count) + '\n')
        i.closed
        check = 0
        coordinate = ' '


testsamtools.closed
g.closed
end = time.time()
print end - start
