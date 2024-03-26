function D = readSolisAscii(fname,avg)
dat = readmatrix(fname,'FileType','text');
S = readlines(fname);

d = SpectrumCapture();
d.fname = fname;
I = contains(S,'Date and Time');
t = extractAfter(S(I),14);
t = datetime(t,'InputFormat','eee MMM dd HH:mm:ss.SSS yyyy');
d.t = posixtime(t);
I = contains(S,'Exposure Time');
d.itime = str2double(reverse(strtok(reverse(S(I)))));
I = contains(S,'Temperature');
d.TEC = str2double(reverse(strtok(reverse(S(I)))));
I = contains(S,'Acquisition Mode');
str = S(I);
if contains(str,'Kinetics')
    I = contains(S,'Accumulations');
    exposures = str2double(reverse(strtok(reverse(S(I)))));
    I = contains(S,'Kinetic Cycle Time');
    dt = str2double(reverse(strtok(reverse(S(I)))));
    I = contains(S,'Number in Kinetics Series');
    N = str2double(reverse(strtok(reverse(S(I)))));
elseif contains(str, 'Single') || contains(str,'Real')
    exposures = 1;
    dt = itime;
    N = 1;
end

d.x = dat(:,1);
if avg
    d.counts = mean(dat(:,2:N+1),2);
    d.SumCounts();
    d.Navg = N;
    D = copy(d);
else
    D = repmat(d,1,N);
    for i = 1:N
        d.counts = dat(:,1+i);
        d.SumCounts();
        if i>1; d.t = D(1).t + dt; end
        D(i) = copy(d);
    end
end

end