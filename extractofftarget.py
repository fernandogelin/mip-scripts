import pysam, string, sys

input1 = sys.argv[1] # bedfile
input2 = sys.argv[2] # bamfile
input3 = sys.argv[3] # output


h = open(input1, 'r')
t = 0
output = open(input3, 'a')

z = 0

for line in h:
    stri = line.split()
    chromosome = stri[0]
    start = stri[1]
    if int(stri[1]) == 0:
        start = 1
        start = str(start)
           
    coordinate = "chr" + chromosome[3:] + ':' + start + '-' + stri[2]
    print coordinate
    samfile = pysam.Samfile(input2, "rb" )
    iter = samfile.fetch( region= (coordinate) )
    for AlignedRead in iter:
        
        output.write('@' + AlignedRead.qname + ' ' + str(stri[0]))
        output.write('\n')
        output.write(AlignedRead.query)
        output.write('\n')
        output.write('+')
        output.write('\n')
        output.write(AlignedRead.qqual)
        output.write('\n')
            
            
    samfile.close()
    z = 0

    
h.closed
output.closed



