import os
import numpy as np

#postprocess the output from paraview into a file
#based on the template
#lat,lon,disp_x,disp_y,disp_z

#Seissol output prefix
prefix = 'sumatra'
#index of first and last+1 gps receivers
indexgps0 = 0
indexgps1 = 31

import mpl_toolkits.basemap.pyproj as pyproj
lla = pyproj.Proj(proj='latlong', ellps='WGS84', datum='WGS84')
sProj = "+init=%s" %"EPSG:32646"
myproj=pyproj.Proj(sProj)

fout = open('gps_synth.dat','w')
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

   fout.write('%.3f,%.3f,%f,%f,%f\n' %(xyz[0],xyz[1],dx,dy,dz))
fout.close()
print 'done!'
