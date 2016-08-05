import numpy as np
import os
from math import floor,sqrt

#prefix='sumatra'
#folder='OutputSumatraLong'
#nrec=5490
#nx=61
#X0=-112587.5383730000
#Y0=-222089.5187140000
#inc=2.5e4

prefix='dip10'
folder='OUTPUTDIP10/Outputdip10-inc-plas-m2'
nrec=3111
nx=50
X0=-20000.000000
Y0=-75000.000000 
inc=2.5e3
yprofile=0.

ny=nrec/nx
aDisp = np.zeros((nx,ny))

fout=open('finaldisp_profile.dat','w')

import glob
ReceiverFileList = glob.glob('%s/%s-receiver-*' %(folder, prefix))

for id in range(0,nrec):
   mytemplate='%s/%s-receiver-%05d' %(folder, prefix, id+1)
   MatchingFiles = [s for s in ReceiverFileList if mytemplate in s]
   #Error Handling
   if len(MatchingFiles)==0:
      print("no file matching "+mytemplate)
      exit()
   elif len(MatchingFiles)>1: 
      print("more than a file matching "+mytemplate)
      print(MatchingFiles)
      exit()
   myfile=MatchingFiles[0]
   #print(myfile)

   #Read coordinates
   fid = open(myfile)
   fid.readline()
   fid.readline()
   xc= float(fid.readline().split()[2])
   yc= float(fid.readline().split()[2])
   zc= float(fid.readline().split()[2])
   fid.close()
   if abs(yc-yprofile)>1e-3:
      continue
   #Read data
   test = np.loadtxt(myfile,  skiprows=5)
   dt=test[1,0]
   vx=test[:,7]
   vy=test[:,8]
   vz=test[:,9]

   nval = len(vx)
   dz_string=""
   for itime in range(0,15):
      time=itime*2.5+25
      Nmax = min(nval, time/dt)
      dz = np.trapz(vz[0:Nmax],dx=dt)
      dz_string=dz_string+" %f" %dz
   fout.write("%f %s\n" %(xc, dz_string))

fout.close()

#Now plotting the profiles

import matplotlib.pyplot as plt
import matplotlib.colors as colors
import matplotlib.cm as cmx

fin=open("finaldisp_profile.dat")
test = np.loadtxt(fin)
x=test[:,0]
print(x)
n=len(test[0,:])

# Plot the results
plt.figure()

jet = cm = plt.get_cmap('jet') 
cNorm  = colors.Normalize(vmin=1, vmax=n)
scalarMap = cmx.ScalarMappable(norm=cNorm, cmap=jet)


for i in range(0,n-1):
   colorVal = scalarMap.to_rgba(i)
   y=test[:,i+1]
   leg="%.1fs" %(i*2.5+25)
   plt.plot(x,y,label=leg,color=colorVal)
plt.legend(loc='upper right')
plt.show()
