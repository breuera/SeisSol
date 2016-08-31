#!/bin/bash
gmtset MAP_FRAME_TYPE = fancy \
       PS_MEDIA = a4 \
       PS_PAGE_ORIENTATION = portrait

filename=Sumatra

pscoast -R90/100/0/15 `#region`\
        -Jc100/10/1.0 `#projection`\
        -B5g5 `#grid`\
        -Df `#resolution`\
        -S114/159/207 `#wet fill color`\
        -G233/185/110 `#dry fill color`\
        -Wthinnest `#shoreline pen`\
        -K > $filename.eps

awk -F',' '{if ($1!~/^#/) {print $1,$2,180.*atan2($4,$3)/3.14159,0.3*sqrt($3**2+$4**2)}}' GPSJadeGahalaut.dat >tmp.dat
sort -k1,1 -k2,2 tmp.dat > GPSJadeGahalaut_GMT.dat
awk -F',' '{if ($1!~/^#/) {print $1,$2,90,0.3*$5}}' GPSJadeGahalaut.dat >tmp.dat
sort -k1,1 -k2,2 tmp.dat > GPSJadeGahalaut_vert_GMT.dat
awk -F',' '{if ($1!~/^#/) {print $1,$2,180.*atan2($4,$3)/3.14159,0.3*sqrt($3**2+$4**2)}}' gps_synth.dat >tmp2.dat
sort -k1,1 -k2,2 tmp2.dat > gps_synth_GMT.dat
awk -F',' '{if ($1!~/^#/) {print $1,$2,90,0.3*$5}}' gps_synth.dat >tmp2.dat
sort -k1,1 -k2,2 tmp2.dat > gps_synth_vert_GMT.dat

#site   Long.      Lat.      East    North     sE      sN    Up     sU
awk -F',' '{if ($1!~/^#/) {print $2,$3,180.*atan2($5,$4)/3.14159,0.3*sqrt($4**2+$5**2)/1000.}}' Subarya_et_al_table1.dat > Subarya_et_al_table1_GMT.dat
awk -F',' '{if ($1!~/^#/) {print $2,$3,90,0.3*$8/1000.}}' Subarya_et_al_table1.dat > Subarya_et_al_table1_vert_GMT.dat

#horizontal components
headv=0.05i
gmt psxy -R -Jc -Sv$headv+ea -Gblack -W0.5p -Baf  -K -O GPSJadeGahalaut_GMT.dat >> $filename.eps
gmt psxy -R -Jc -Sv$headv+ea -Gblack -W0.5p -Baf  -K -O Subarya_et_al_table1_GMT.dat >> $filename.eps
gmt psxy -R -Jc -Sv$headv+ea -Gred -W0.5p,red -Baf -K -O gps_synth_GMT.dat >> $filename.eps

#vertical components
gmt psxy -R -Jc -Sv$headv+ea -Gblack -W0.5p -Baf  -K -O GPSJadeGahalaut_vert_GMT.dat >> $filename.eps
gmt psxy -R -Jc -Sv$headv+ea -Gblack -W0.5p -Baf  -K -O Subarya_et_al_table1_vert_GMT.dat >> $filename.eps
gmt psxy -R -Jc -Sv$headv+ea -Gred -W0.5p,red,.. -Baf -K -O gps_synth_vert_GMT.dat >> $filename.eps


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
