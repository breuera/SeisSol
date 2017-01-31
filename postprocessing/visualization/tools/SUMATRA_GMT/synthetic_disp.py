import os
import numpy as np
from math import atan2, pi, sqrt
#postprocess the output from paraview into a file
#based on the template
#lat,lon,disp_x,disp_y,disp_z

#Seissol output prefix
prefix = 'sumatra'
#index of first and last+1 gps receivers
indexgps0 = 0
indexgps1 = 104

import mpl_toolkits.basemap.pyproj as pyproj
lla = pyproj.Proj(proj='latlong', ellps='WGS84', datum='WGS84')
sProj = "+init=%s" %"EPSG:32646"
myproj=pyproj.Proj(sProj)


#we need to load the GPS data for changing the length scale with GPS data
gpsdata=[]
with open('GPSobs.dat','r') as fin:
   for line in fin:
      vals = [float(val) for val in line.split(',')[1:12]]
      gpsdata.append([vals[0],vals[1],vals[4],vals[10]])
gpsdata=np.asarray(gpsdata)
print gpsdata

fout = open('gps_synth.dat','w')
fout.write('#lat lon dx dy dz hangle hnorm noGPSz GPSnorm\n')

for i in range(indexgps0,indexgps1):
   mytemplate='output/%s-receiver-0%04d*' %(prefix,i+1)
   f = os.popen("ls "+mytemplate)
   now = f.read()
   myfile=now.strip()
   print(myfile)
   fid = open(myfile)
   fid.readline()
   fid.readline()
   xgps = float(fid.readline().split()[2])
   ygps = float(fid.readline().split()[2])
   fid.readline()
   xyz = pyproj.transform(myproj, lla ,xgps,ygps,0, radians=False)
   print xyz

   test = np.loadtxt(fid)
   dx = np.trapz(test[:,7], x=test[:,0])
   dy = np.trapz(test[:,8], x=test[:,0])
   dz = np.trapz(test[:,9], x=test[:,0])
   print (dx, dy,dz)
   angle = 180.*atan2(dy,dx)/pi
   norm = sqrt(dx**2+dy**2)

   index = np.where((abs(gpsdata[:,0]-xyz[0])<0.001)&(abs(gpsdata[:,1]-xyz[1])<0.001))
   assert(len(index)==1)
   if np.isnan(gpsdata[index,2]):
      isnan=1
   else:
      isnan=0
    
   fout.write('%.3f,%.3f,%f,%f,%f,%f,%f,%f,%f\n' %(xyz[0],xyz[1],dx,dy,dz, angle,norm, isnan,gpsdata[index,3]))
fout.close()
print 'done!'
