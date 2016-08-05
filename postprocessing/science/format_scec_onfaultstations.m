% script for SCEC TPV10/11 formatting


% ON-fault stations
% assume fault plane in the xy plane

% Christian Pelties, LMU Munich, 16.8.2011
% pelties@geophysik.uni-muenchen.de
% Thomas Ulrich, LMU Munich, 2016
% ulrich@geophysik.uni-muenchen.de

clear

add_tpv104_nucleation = false
speedupByResampling = true

% load data
data=loadmatfile('aaa.mat');


[timesteps variables nr_stations] = size(data.data);
str3 = date;
timestep = data.data(2,1,1)-data.data(1,1,1); % timestep length
dt = timestep;

if variables==9
    has_psi=true;
else
    has_psi=true;
end
out(:,1,:) = data.data(:,1,:); % time

% integrate slip rate
var = 2;
s(1:timesteps,1:nr_stations)=0.0;
for j=1:nr_stations    

   s(1,j) = data.data(1,var,j);
   for i = 2:timesteps
            s(i,j) = s(i-1,j)+dt*data.data(i,var,j);
    end
end

out(:,2,:) = s(:,:); % horizontal slip
out(:,3,:) = data.data(:,2,:); % horizontal slip rate
out(:,4,:) = data.data(:,4,:); % horizontal shear stress

var = 3;
s(1:timesteps,1:nr_stations)=0.0;
for j=1:nr_stations
    s(1,j) = data.data(1,var,j);
    for i = 2:timesteps
        s(i,j) = s(i-1,j)+dt*data.data(i,var,j);
    end
end

out(:,5,:) = s(:,:); % vertical slip
out(:,6,:) = data.data(:,3,:); % vertical slip rate
out(:,7,:) = data.data(:,5,:); % vertical shear stress
out(:,8,:) = data.data(:,6,:); % normal stress
if has_psi
   out(:,9,:) = data.data(:,9,:); % psi  
end

% correct for individual heterogeneous ini shear stress
% and correct for cohesion
for i = 1:nr_stations
        out(:,4,i) = (out(:,4,i)+data.bg(2,i))./1.0e6;
        out(:,7,i) = (out(:,7,i)+data.bg(3,i))./1.0e6;
        out(:,8,i) = (out(:,8,i)-data.bg(1,i))./1.0e6;
    end
    

if add_tpv104_nucleation
   disp ('!!!ADDING time-space dependant nucleation Stress!!!')
   Rnuc=3e3;
   Tnuc=1.0;
   nNucl = floor(Tnuc/dt);
       
   for i=1:nr_stations
       radius=sqrt(data.location(1,i)^2+(data.location(3,i)+7500.0D0)^2);
       if radius<Rnuc
	   Fnuc=exp(radius^2/(radius^2-Rnuc^2));
	   for j = 2:nNucl
	      time  = dt*j;
	      Gnuc=exp((time-Tnuc)^2/(time*(time-2.0D0*Tnuc)));
	      out(j,4,i) = out(j,4,i) + 45*Fnuc*Gnuc;
	   end
	   out(nNucl+1:timesteps,4,i) = out(nNucl+1:timesteps,4,i) + 45*Fnuc;
       end
   end
end
    
    
% %nucleation patch special correction
% out(:,4,1) = (out(:,4,1)+data.bg(2,1))./1.0e6;
% out(:,7,1) = (out(:,7,1)+data.bg(3,1))./1.0e6;
% out(:,8,1) = (out(:,8,1)+data.bg(1,1))./1.0e6;

if speedupByResampling
   nDiv = floor(5e-3/timestep);
   if nDiv>1 
       %resample : less data
       msg=sprintf('resampling here, keeping 1 sample every %d samples!!!!', nDiv);
       disp(msg);
       
       tmp=out(nDiv:nDiv:end,:,:);
       out=tmp;
       
       [timesteps variables nr_stations] = size(out);
       timestep = nDiv*timestep; % timestep length
       dt = timestep;
   end
end

it=0;
  
for i = 1:nr_stations
    it=it+1;
     
    %compute given file name
    if sign(data.location(1,i)/100)==-1
        sSign1='-';
    else
        sSign1='';         
    end

    %special case of 0
    if abs(data.location(1,i)/100)<1
        sSign1='';
    end

    sSign3=''; 
    
    sFileName = sprintf('/export/data/ulrich/faultst%s%03ddp%s%03d.dat', ...
        sSign1,abs(round(data.location(1,i)/100)),sSign3,abs(round(data.location(3,i)/100)));
    msg = sprintf('now processing %s', sFileName);
    disp(msg);
    
    fid=fopen(sFileName,'w');
    fprintf(fid,'# problem=TPV104\n');
    fprintf(fid,'# author=Thomas ULRICH\n');
    fprintf(fid,['# date=',str3,'\n']);
    fprintf(fid,'# code=SeisSol (ADER-DG) with plasticity\n');
    fprintf(fid,'# Background stress is assigned to each individual Gaussian integation point (GP)\n');    
%    fprintf(fid,'# Background stress is assigned to a complete element determined by its geometrical barycenter\n');
    fprintf(fid,'# element_size=250 m on fault 5000m far away Growth rate 1.10\n');
    fprintf(fid,'# 1,66e6 tetra elements\n');
    fprintf(fid,'# order of approximation in space and time= O5\n');
    fprintf(fid,'# time_step= %e \n',timestep);
    fprintf(fid,'# num_time_steps= %d \n',timesteps);
    fprintf(fid,'# location= on fault, %d m along strike, %d m down-dip\n',data.location(1,i),-data.location(3,i));
    fprintf(fid,'# Column #1 = Time (s)\n');
    fprintf(fid,'# Column #2 = horizontal slip (m)\n');
    fprintf(fid,'# Column #3 = horizontal slip rate (m/s)\n');
    fprintf(fid,'# Column #4 = horizontal shear stress (MPa)\n');
    fprintf(fid,'# Column #5 = vertical slip (m)\n');
    fprintf(fid,'# Column #6 = vertical slip rate (m/s)\n');
    fprintf(fid,'# Column #7 = vertical shear stress (MPa)\n');
    fprintf(fid,'# Column #8 = normal stress (MPa)\n');
    if has_psi
        fprintf(fid,'# Column #9 = state variable psi\n');
    end
    fprintf(fid,'#\n');
    fprintf(fid,'# The line below lists the names of the data fields:\n');
    if has_psi
       fprintf(fid,'t h-slip h-slip-rate h-shear-stress v-slip v-slip-rate v-shear-stress n-stress psi\n');
    else
       fprintf(fid,'t h-slip h-slip-rate h-shear-stress v-slip v-slip-rate v-shear-stress n-stress\n');
    end
    fprintf(fid,'#\n');
    fprintf(fid,'# Time-series data:\n');
    %0.000000E+00 0.000000E+00 0.000000E+00 7.000000E+01 0.000000E+00 ...
    for j = 1:timesteps

    if has_psi
       fprintf(fid,'%21.13e %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e \n', ...
                out(j,1,i),out(j,2,i),out(j,3,i),out(j,4,i),out(j,5,i),out(j,6,i),out(j,7,i),out(j,8,i),out(j,9,i));
    else
       fprintf(fid,'%21.13e %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e \n', ...
                out(j,1,i),out(j,2,i),out(j,3,i),out(j,4,i),out(j,5,i),out(j,6,i),out(j,7,i),out(j,8,i));
    end
    
    end;
    
    % close file
    fclose(fid);



end;

disp('Done!')
