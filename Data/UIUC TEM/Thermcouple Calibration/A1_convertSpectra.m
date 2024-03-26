
% Convert text files into SpectrumCapture objects

% File names chosen during the session:
inNames = {'spectrometer/dark_%02u.txt'   ,... % <-- Dark spectra for measuring offset, dark current
           'spectrometer/zadj_%05u*'      ,...
           'spectrometer/heating_%04u*'   ,...
           'spectrometer/continuous_%05u*',...
           'spectrometer/continuous2_%05u*'};  % <-- The files with the laser power ramp used for calibration

outNames = {'dark','zadj','heating','cont1','cont2'};
outLengths = [20,700,10,6956,18030];
d = SpectrumCapture(); % Initialize empty spectrum object

for j = 1:numel(outLengths)
    clear D
    D = repmat(d,1,outLengths(j));
    timestamp = NaN([1 outLengths(j)]);
    
    for i = outLengths(j):-1:1
        fname = sprintf(inNames{j},i-1);
        fname = dir(fname);
        fname = fname(end);
        fname = [fname.folder '\' fname.name];
        a = System.IO.File.GetCreationTime(fname);
        timestamp(i) = a.Ticks;
        [c, d.itime, x] = loadSpectrum(fname,[],[]);
        d.counts = c(5:1040); % Trim invalid pixels from each end
        D(i) =  copy(d);
    end
    % 
    % CAUTION: creation dates must be intact. Use Windows 'robocopy' command when transferring files made by this OeanOptics program
    % 
    t = timestamp - timestamp(1);
    for i = 1:numel(D)
        D(i).t = double(t(i))/1e7;
        D(i).countss = sum(D(i).counts);
    end
    x = x(5:1040);
    save(['spectrometer/Spectra_' outNames{j} '.mat'],'D','x');
end
