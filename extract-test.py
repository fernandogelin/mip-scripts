import pysam, string, sys, os, subprocess, glob

input1 = sys.argv[1] # MIP file
barcode = sys.argv[2] # Barcode
input3 = sys.argv[3] # Stringency
input4 = sys.argv[4] # samfile to clean
input5 = sys.argv[5] # clean outputfile sam
input6 = sys.argv[6] # working directory

stringency = int(input3)

#h = open(input1, 'r')
t = 0

z = 0
Barcode = 1
#homeuser = os.path.expanduser("~")
samsplit = '@@@@@@@$$$$$$$$$$$&&&&&&&&@@@'
splitting = '@@@@@@@$$$$$$$$$$$&&&&&&&&@@@'
    


samfile = open(input4, 'r')

listgood = set([])  

for filename in glob.glob(os.path.join(input6, '*/*_good_*')):
        good = open(filename, 'r')
        #print filename
        for line in good:
            if line.find('/3_orig_bc') != -1 and line.find('@Barcode') != -1:
                splitting = line.split("3_orig_bc",1)[0]
                splitting2 = splitting[1:]
                #print splitting
                listgood.add(splitting2)
        good.closed

cleanfile = open(input5, 'a')
print 'searching out1.sam'
            
for line in samfile:
    samline = line
    samline2 = line[0:3]
#    print line
    if line.find('/3_orig_bc') != -1:
        splitting = line.split("3_orig_bc",1)[0]
    if line.find('/1_orig_bc') != -1:
        splitting = line.split("1_orig_bc",1)[0]
    splitting2 = splitting
#    print splitting2
    if splitting2 in listgood or samline2.find('@SQ') != -1 or samline2.find('@RG') != -1:
        cleanfile.write(samline)
#        print 'clean'
#        print samline
#    else:
#        print 'not there'

