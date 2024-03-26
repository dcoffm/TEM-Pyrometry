
%% Load things
load('spectra/Spectra_Heating.mat','D','Ttrue')
emiss_thermocouple = readmatrix('Ta_emissivity_24.csv'); % Gatan holder furnace is made of tantalum
emiss_thermocouple = interp1(emiss_thermocouple(:,1),emiss_thermocouple(:,2),D(1).x,'linear','extrap');

%% Initialize spectrometer class
C = Spec_Cal_fixed();
C.x = D(1).x;
I = 5:numel(D);  % Only 400°C and above are usable
C.D = D(I);
C.L = zeros(size(C.D)); % No laser used with commercial joule heating holder
C.dataMask = ones(size(C.x));
C.Ttrue = Ttrue(I);
C.EmissTrue = emiss_thermocouple;
C.Iassume = numel(C.D); % Use highest temperature spectrum as the reference

% Create parameter/seed structure
C.seedAppend('ADCoffset', 296, 0, 500);
C.seedAppend('BoxFactor', 3.808e-3, 0, 5e-2);

%% Compute
C.Initialize();
C.Iterate(120);
C.Visualize(1:C.nd);

figure; hold on; for i = 1:C.nd; plot(C.D(i).counts - C.ModelCounts(:,i)); end  % Where are differences occuring?

%% Create final  TSE curve
temp = movmean(C.TSE,5); C.TSE(1:800) = temp(1:800);
A = C.TSE.*C.FOV;
C.FOV = max(A);
C.TSE = A./C.FOV;

figure; plot(C.x,C.TSE); xlabel('Wavelength (nm)'); ylabel('Total System Efficiency'); xlim([450 1000.1])

C_cal = copy(C);
C_cal.PlotHandles = [];
C_cal.DatasetLabel = 'Gatan 652 Heated TEM holder, calibration using fixed (tantalum) emissivity';
fname = sprintf('SpecModel_Andor_TaCal_%16s.mat',datestr(clock,'YYYY_mm_dd_HH_MM'));
save(fname,'C_cal'); % Once saved, move this to your calibrations folder
