% script for SCEC formatting

% OFF-fault stations
% assume fault plane in the xz plane

% Alice Gabriel, LMU Munich, 12.11.2012
% gabriel@geophysik.uni-muenchen.de
% Thomas Ulrich, LMU Munich, 2016
% ulrich@geophysik.uni-muenchen.de
clear
%Reformat_ADERDG_Seismograms;

% load data
load('aaa.mat');
data=d;

[timesteps variables nr_stations] = size(data.data);
str3 = date;
timestep = data.data(2,1,1); % timestep length
dt = timestep;

% convert data into SCEC format/order - heterogeneous ini shear stress
for ii=1:nr_stations
    
    out(:,1,ii) = data.data(:,1,ii);    % time
    hdispl(1)=0.0;
    for i = 2:timesteps;
        hdispl(i) = hdispl(i-1)+dt*data.data(i,8,ii);
    end
    out(:,2,ii) = hdispl(:);    % horizontal displacement
    out(:,3,ii) = data.data(:,8,ii);    % horizontal velocity
    vdispl(1)=0.0;
    for i = 2:timesteps;
        vdispl(i) = vdispl(i-1)-dt*data.data(i,10,ii);
    end    
    out(:,4,ii) = vdispl(:);          % vertical displacement
    out(:,5,ii) = -data.data(:,10,ii);          % vertical velocity
    ndispl(1)=0.0;
    for i = 2:timesteps;
        ndispl(i) = ndispl(i-1)+dt*data.data(i,9,ii);
    end
    out(:,6,ii) = ndispl(:);     % normal displacement
    out(:,7,ii) = data.data(:,9,ii);    % normal velocity
    
    clear ndispl vdispl hdispl

end


for i = 1:nr_stations
     %Generate SCEC file name in function of location
     if sign(data.location(1,i)/100)==-1
         sSign1='-';
     else
         sSign1='';         
     end
     if sign(data.location(2,i)/100)==-1
         sSign2='-';
     else
         sSign2='';         
     end
     
     if sign(data.location(3,i)/100)==1
         sSign3='-';
     else
         sSign3='';         
     end

    %special case of 0
    if abs(data.location(1,i)/100)<1
        sSign1='';
    end
    if abs(data.location(2,i)/100)<1
        sSign2='';
    end
    if abs(data.location(3,i)/100)<1
        sSign3='';
    end
    
     sFileName = sprintf('/export/data/ulrich/body%s%03dst%s%03ddp%s%03d.dat', ...
        sSign2,abs(round(data.location(2,i)/100)),sSign1,abs(round(data.location(1,i)/100)),sSign3,abs(round(data.location(3,i)/100)));
    
    msg = sprintf('now processing %s', sFileName);
    disp(msg);    
    
    % open file
    fid=fopen(sFileName,'w');
    fprintf(fid,'# problem=TPV35\n');
    fprintf(fid,'# author=Thomas ULRICH\n');
    fprintf(fid,['# date=',str3,'\n']);
    fprintf(fid,'# code=SeisSol (ADER-DG)\n');
    fprintf(fid,'# Background stress is assigned to each individual Gaussian integation point (GP)\n');    
    %fprintf(fid,'# Background stress is assigned to a complete element determined by its geometrical barycenter\n');
    %fprintf(fid,'# element_size=50 m on fault 5000m far away Growth rate 1.15, Normal Stress o1\n');
    fprintf(fid,'# element_size=200 m on fault 2500m far away coarsening ratio 0.10\n');
    fprintf(fid,'# 4,00e6 tetra elements\n');
    fprintf(fid,'# order of approximation in space and time= O5\n');
    fprintf(fid,'# time_step= %e \n',timestep);
    fprintf(fid,'# num_time_steps= %d \n',timesteps);
    fprintf(fid,'# location= %10.2f km off fault, %10.2f km along strike, %10.2f km depth\n',data.location(2,i)/1000, data.location(1,i)/1000,-data.location(3,i)/1000);
    fprintf(fid,'# Column #1 = Time (s)\n');
    fprintf(fid,'# Column #2 = horizontal displacement (m)\n');
    fprintf(fid,'# Column #3 = horizontal velocity (m/s)\n');
    fprintf(fid,'# Column #4 = vertical displacement (m)\n');
    fprintf(fid,'# Column #5 = vertical velocity (m)\n');
    fprintf(fid,'# Column #6 = normal displacement (m/s)\n');
    fprintf(fid,'# Column #7 = normal velocity (m)\n');
    fprintf(fid,'#\n');
    fprintf(fid,'# The line below lists the names of the data fields:\n');
    fprintf(fid,'t h-disp h-vel v-disp v-vel n-disp n-vel\n');
    fprintf(fid,'#\n');
    fprintf(fid,'# Time-series data:\n');
    %0.000000E+00 0.000000E+00 0.000000E+00 7.000000E+01 0.000000E+00 ...
    for j = 1:timesteps
    fprintf(fid,'%21.13e %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e \n', ...
                out(j,1,i),out(j,2,i),out(j,3,i),out(j,4,i),out(j,5,i),out(j,6,i),out(j,7,i));
    end;
    
    % close file
    fclose(fid);

end;

disp('Done!')
