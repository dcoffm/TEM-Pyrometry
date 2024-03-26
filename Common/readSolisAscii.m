function D = readSolisAscii(fname,avg)
dat = readmatrix(fname,'FileType','text');
S = readlines(fname);

D.fileName = fname;
I = contains(S,'Exposure Time');
D.itime = str2double(reverse(strtok(reverse(S(I)))));    
I = contains(S,'Temperature');
D.TEC = str2double(reverse(strtok(reverse(S(I)))));
I = contains(S,'Acquisition Mode');
str = S(I);
if contains(str,'Kinetics')
    I = contains(S,'Accumulations');
    D.exposures = str2double(reverse(strtok(reverse(S(I)))));
    I = contains(S,'Kinetic Cycle Time');
    D.dt = str2double(reverse(strtok(reverse(S(I)))));
    I = contains(S,'Number in Kinetics Series');
    D.N = str2double(reverse(strtok(reverse(S(I)))));
elseif contains(str, 'Single') || contains(str,'Real')
    D.exposures = 1;
    D.dt = D.itime;
    D.N = 1;
end

D.x = dat(:,1);
if avg
    D.counts = mean(dat(:,2:D.N+1),2);
else
    D.counts = dat(:,2:D.N+1);
end
D.cps = D.counts.*NaN; % Make an empty counts-per-second field for later processing
end