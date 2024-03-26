
di = dir('spectra/');
ilist = 44:59; % file name indices of interest
Ttrue = [];
N = numel(ilist);
d = SpectrumCapture();
D = repmat(d,1,N);
for i = 1:N
    I = contains({di.name},sprintf('%04u.asc',ilist(i)));
    fname = di(I).name;
    Ttrue(i) = str2double(strtok(fname,'C'));
    d = readSolisAscii(['spectra\' fname],true);
    D(i) = copy(d);
end
Ttrue(end)=1000; % Labeled as 999 for neatness
save('spectra/Spectra_Heating.mat','D','Ttrue');