import numpy as np
#T. Ulrich 27.01.2016
#remove duplicate GPS stations

mydtype={'names': ('name','lat','lon','dn','de','du','sn','se','su','hangle','hnorm','norm'), 'formats': ('S10', 'f4', 'f4','f4', 'f4','f4', 'f4','f4','f4', 'f4','f4', 'f4')}

mydata = np.loadtxt('GPSobsIni.dat',dtype = mydtype, delimiter=',',comments='#')
print mydata[:]['name']

pickedStation=[]
row2remove=[]
nitem =  len(mydata)
for i in range(nitem):
    if mydata[i]['name'] in pickedStation:
       row2remove.append(i)
    else:
       pickedStation.append(mydata[i]['name'])

mydata = np.delete(mydata, tuple(row2remove), axis=0)
print len(mydata)
np.savetxt('GPSobs.dat',mydata,delimiter=',', comments="#",fmt='%s,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f',)
