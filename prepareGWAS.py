#!/usr/bin/python

import csv
import sys
import re

#print '*******Usage:*******************************'
#print './nameofProgram.py input_gwas_sum_statistics_with_SNPID_P_INFO_A1_A2_fields 1000g_reference.bim output_name\n'
#print '*******Number of arguments:*****************'
#print len(sys.argv)-1, 'arguments.\n'
#print '*******Program name and argument list:******' 
#print str(sys.argv)
#print ''

infile=sys.argv[1]
referencefile=sys.argv[2]
outfile = sys.argv[3]

#read reference SNPs
refsnp={}
with open(referencefile, 'rb') as Frefsnp:
	for line in Frefsnp:
		splitit=line.strip().split('\t')
		refsnp[splitit[1]]=[splitit[4].upper(),splitit[5].upper()]
#read header GWAS statistics
#f = open(infile, 'rb')
#dialect = csv.Sniffer().sniff(f.read(1024))
#f.seek(0)
#reader = csv.reader(f,delimiter="\t| ")
with open(infile, 'rb') as fin:
	headline = fin.next().strip().split();
	headers = [x.upper() for x in headline] 
	print "********GWAS Header:*********"
	print headers
	isInfo=False
	Infodic=["INFO","QUAL"]
        Pdic=["P_ADJ","PVALUE","P","PVAL","P-VALUE","FREQUENTIST_ADD_PVALUE","P.VALUE","P_VAL","GC_PVALUE","META.PVAL","P.ADD","P_VALUE"]
	SNPdic=["SNP","SNPID","MARKERNAME","RSID","RS_NUMBER","MARKER","RS","RSNUMBER","RS_NUMBERS","SNP.NAME","SNP ID","SNP_ID","RS_NUMBER"]
	A1dic=["A1","EFFECT_ALLELE","ALLELEB","REFERENCE_ALLELE","EA","ALLELE_1","EFFECT_ALLELE","INC_ALLELE","ALLELE1","A"]
	A2dic=["A2","NEFFECT_ALLELE","OTHER_ALLELE","ALLELEA","NEA","NON_EFFECT_ALLELE","DEC_ALLELE","NEA","ALLELE2","ALLELE0","B"]
	MAFdic=["FRQ","MAF","EAF"]
	defP=list(set(headers).intersection(Pdic))
	defSNP=list(set(headers).intersection(SNPdic))
	defA1=list(set(headers).intersection(A1dic))
	defA2=list(set(headers).intersection(A2dic))
	defMAF=list(set(headers).intersection(MAFdic))
        defInfo=list(set(headers).intersection(Infodic))
	print ""
# check fields

	if not defInfo:
		print "Missing INFO field: won't be taking INFO into account"
		isInfo=False
	else:
		print "Found INFO field: ",
		print defInfo[0]
		infoindex=headers.index(defInfo[0])
		isInfo=True
	
	if not defSNP:
		print "Missing SNPID field"
		quit()
	else:
        	print "Found SNPID field: ",
 		print defSNP[0]
		snpindex=headers.index(defSNP[0])

	if not defP:
		print "Missing P field"
		quit()
	else:
		print "Found P field: ",
		print defP[0]
		pindex=headers.index(defP[0])

	if not defA1:
		print "Missing A1 field"
		quit()
	else:
		print "Found A1 field",
		print defA1[0]
		a1index=headers.index(defA1[0])

	if not defA2:
		print "Missing A2 field"
		quit()
	else:
		print "Found A2 field",
		print defA2[0]
		a2index=headers.index(defA2[0])
#        if not defMAF:
#                print "No MAF field: no MAF filter"
#                quit()
#        else:
#                print "Found MAF field"
#                mafindex=headers.index(defMAF[0])

	countOrig=0;
	countSNP=0;
	countINFO=0;
	countALLELEMISS=0;

	print "Now wait for me to filter your variants. It could take 2-3 minutes."

	if isInfo==False:
		with open(outfile, 'w') as out:
			out.write('SNP\tP\n')
			for line in fin:
			        row=line.strip().split()
				countOrig+=1;
				try:
					cleanRSID=re.sub('^23:','X:',re.sub('^chr','',re.sub('_', ':', row[snpindex])))
				except:
					print "no id at row ",
					print countOrig
					cleanRSID="NORSID"
					pass
				if (cleanRSID in refsnp):
					countSNP+=1;
					listAR=set([row[a1index].upper(),row[a2index].upper()])
					listCHECK=set(refsnp[cleanRSID])
					listDI=set(["D","I"])
					if((listAR==listCHECK)|(listAR==listDI)):
						countALLELEMISS+=1
					#delete item in dictionary to avoid duplicates and be faster
                         	                del refsnp[cleanRSID];
                                	        out.write("%s\t%s\n" % (cleanRSID,row[pindex]))

	elif isInfo==True:
		with open(outfile, 'w') as out:
			out.write('SNP\tP\n')
			for line in fin:
                                row=line.strip().split()
				countOrig+=1;
				try:
					cleanRSID=re.sub('^23:','X:',re.sub('^chr','',re.sub('_', ':', row[snpindex])))
				except:
                                	print "no id at row ",
                                	print countOrig
                                	cleanRSID="NORSID"
					pass
				if (cleanRSID in refsnp):
					countSNP+=1;
					if(float(row[infoindex])>0.6):
						countINFO+=1;
						listAR=set([row[a1index].upper(),row[a2index].upper()])
						listCHECK=set(refsnp[cleanRSID])
						listDI=set(["D","I"])
						if((listAR==listCHECK) or (listAR==listDI)):# and ((float(row[headers.index("FRQ_A_3495")])>=0.01) or (float(row[headers.index("FRQ_U_10982")])>=0.01)):
							countALLELEMISS+=1
						#delete item in dictionary to avoid duplicates and be faster
							del refsnp[cleanRSID];
							out.write("%s\t%s\n" % (cleanRSID,row[pindex]))
		out.close()
	fin.close()
print "Total number of variants: ",
print countOrig
print "After 1000 G filter (MAF<0.01): ",
print countSNP
if isInfo==True:
	print "After INFO filter: ",
	print countINFO
print "After Allele mismatch filter: ",
print countALLELEMISS
