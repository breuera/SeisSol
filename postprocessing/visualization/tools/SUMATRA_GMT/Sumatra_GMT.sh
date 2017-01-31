#!/bin/bash
gmtset MAP_FRAME_TYPE = fancy \
       PS_MEDIA = a4 \
       PS_PAGE_ORIENTATION = portrait

filename=Sumatra

pscoast -R90/105/0/15 `#region`\
        -Jc100/10/1.0 `#projection`\
        -B200g200 `#grid`\
        -Df `#resolution`\
        -S114/159/207 `#wet fill color`\
        -G233/185/110 `#dry fill color`\
        -Wthinnest `#shoreline pen`\
        -K > $filename.eps



#preprocessing psxy input file for horizontal obs GPS
awk -F',' '{if (($1!~/^#/)&&($12>0.5)) {print $2,$3,$10,0.3*$11}}' GPSobs.dat >tmp.dat
sort -k1,1 -k2,2 tmp.dat > GPSobs1_GMT.dat
#preprocessing psxy input file for vertical obs GPS
awk -F',' '{if (($1!~/^#/)&&($12>0.5)) {print $2,$3,90,0.3*$6}}' GPSobs.dat >tmp.dat
sort -k1,1 -k2,2 tmp.dat > GPSobs1_vert_GMT.dat
#preprocessing psxy input file for horizontal obs GPS
awk -F',' '{if (($1!~/^#/)&&($12<0.5)) {print $2,$3,$10,6*$11}}' GPSobs.dat >tmp.dat
sort -k1,1 -k2,2 tmp.dat > GPSobs2_GMT.dat
#preprocessing psxy input file for vertical obs GPS
awk -F',' '{if (($1!~/^#/)&&($12<0.5)) {print $2,$3,90,6*$6}}' GPSobs.dat >tmp.dat
sort -k1,1 -k2,2 tmp.dat > GPSobs2_vert_GMT.dat

#preprocessing psxy input file for horizontal synthetics
awk -F',' '{if (($1!~/^#/)&&($9>0.5)) {print $1,$2,$6, 0.3*$7}}' gps_synth.dat >tmp.dat
sort -k1,1 -k2,2 tmp.dat > GPSsynth1_GMT.dat
#preprocessing psxy input file for vertical synthetics
awk -F',' '{if ((($1!~/^#/)&&($9>0.5))&&($8==0)) {print $1,$2,90,0.3*$5}}' gps_synth.dat >tmp.dat
sort -k1,1 -k2,2 tmp.dat > GPSsynth1_vert_GMT.dat
#preprocessing psxy input file for horizontal synthetics
awk -F',' '{if (($1!~/^#/)&&($9<0.5)) {print $1,$2,$6, 6*$7}}' gps_synth.dat >tmp.dat
sort -k1,1 -k2,2 tmp.dat > GPSsynth2_GMT.dat
#preprocessing psxy input file for vertical synthetics
awk -F',' '{if (($1!~/^#/)&&($9<0.5)&&($8==0)) {print $1,$2,90,6*$5}}' gps_synth.dat >tmp.dat
sort -k1,1 -k2,2 tmp.dat > GPSsynth2_vert_GMT.dat

#horizontal components
headv=0.05i
gmt psxy -R -Jc -Sv$headv+ea -Gblack -W0.5p -Baf  -K -O GPSobs1_GMT.dat >> $filename.eps
gmt psxy -R -Jc -Sv$headv+ea -Gblack -W0.5p,blue -Baf  -K -O GPSobs2_GMT.dat >> $filename.eps
gmt psxy -R -Jc -Sv$headv+ea -Gred -W0.5p,red -Baf -K -O GPSsynth1_GMT.dat >> $filename.eps
gmt psxy -R -Jc -Sv$headv+ea -Gred -W0.5p,red -Baf -K -O GPSsynth2_GMT.dat >> $filename.eps

#vertical components
gmt psxy -R -Jc -Sv$headv+ea -Gblack -W0.5p -Baf  -K -O GPSobs1_vert_GMT.dat >> $filename.eps
gmt psxy -R -Jc -Sv$headv+ea -Gblack -W0.5p,blue -Baf  -K -O GPSobs2_vert_GMT.dat >> $filename.eps
gmt psxy -R -Jc -Sv$headv+ea -Gred -W0.5p,red,.. -Baf -K -O GPSsynth1_vert_GMT.dat >> $filename.eps
gmt psxy -R -Jc -Sv$headv+ea -Gred -W0.5p,red,.. -Baf -K -O GPSsynth2_vert_GMT.dat >> $filename.eps


#gmt psxy sumatra_fault_all.dat -R -Jc -Sf0.8i/0.1i+l+t -Gwhite -W -B10 -K -O >>$filename.eps
#gmt psxy trench.dat  -R -Jc -W -K -O >>$filename.eps
gmt psxy sumatra_fault_all.dat  -R -Jc -W0.5p,blue -K -O >>$filename.eps


pstext -R -Jc -N -O << EOF >> $filename.eps
91 3 24 0 14 BL @:12:observations
91 2 24 0 14 BL @:12:@;red;synthetics
EOF

epstopdf --outfile=$filename.pdf $filename.eps
rm tmp*
rm *_GMT.dat 
rm $filename.eps
