#/bin/sh
#transform a pl file (Gocad) into a  file readable by psxy (gmt)
awk '$1=="VRTX" {printf("%f\t%f\n",$3,$4)} elif $1=="ILINE" {print ">\taa"}'
