import pysam, string, sys

input1 = sys.argv[1] # MIP-file
input2 = sys.argv[2] # fastq to extract
# input3 = sys.argv[3] # output


f = open(input1, 'r')


counter = 0
z = 0

for line in f:
        miplist = line.split()
        extension = miplist[5]
        extension = extension[1:-1]
        ligation = miplist[9]
        ligation = ligation[1:-1]
        print miplist[0]
        print extension
        print ligation
        g = open(input2, 'r')
        counter = counter + 1
        out = open((miplist[0] + '-' + str(counter) + '.fastq'), 'a')
        for line in g:
                if z == 0:
                        firstline = line
                elif z == 1:
                        secondline = line
                        question2 = line.find(extension)
                        question3 = line.find(ligation)
                elif z == 2:
                        thirdline = line
                elif z == 3:
                        fourthline = line
                        z = -1
                        if question2 > -1 or question3 > -1:
                                out.write(firstline + secondline + thirdline + fourthline)
                                question2 = -2
                                question3 = -2
                z = z + 1
        extension = ' '
        ligation = ' '
        g.closed
        out.closed
f.closed
		
