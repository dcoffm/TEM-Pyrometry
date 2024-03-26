function [spectrum,itime,wavelength] = loadSpectrum(fname,ADC_offset,DarkCPS)
% Load a spectrum from OceanOptics file and optoinally do ADC and dark current substraction if provided

% fname  = file name of spectrum (text file)
% ADC_offset = a scalar associated with the reference voltage taken as "zero" by the counter circuit

    data = readmatrix(fname);
    wavelength = data(:,1);
    spectrum = data(:,2);
    str = fileread(fname);
    
    if strcmp(str(1:12),'SpectraSuite')
        str = regexp(str,'Integration Time.*','match','dotexceptnewline');
        itime = 1e-6*str2double(regexp(str{:},'[0-9]+\s','match'));
        wavelength(end) = []; % it also has an extra row with NaN for some reason
        spectrum(end) = [];
    else
        str = regexp(str,'Integration Time.*','match','dotexceptnewline');
        itime = str2double(regexp(str{:},'\d.*','match'));
    end
        
    % For some reason a small subset of pixels is shifted around by the OceanOptics program:
    spectrum = [spectrum(1025:1034); spectrum(1:1024); spectrum(1035:1044)];
	
	if isempty(DarkCPS)
		DarkCPS = zeros(size(spectrum));
	end
	if isempty(ADC_offset)
		ADC_offset = 0;
	end
	
    spectrum = spectrum-ADC_offset-DarkCPS*itime;
	spectrum(spectrum>5.5e4) = NaN; % avoid nonlinearity issues by throwing away any points above 50k (out of 65k)
end