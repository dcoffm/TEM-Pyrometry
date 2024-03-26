
%% Load things
load('spectrometer/Spectra_cont2.mat','D','x')
load('potentiostat/Thermocouple_cont2.mat','t_therm','V_smooth')
load('potentiostat/TC_lookup_22.5C.mat','T_lookup','V_lookup','a_lookup') 

emiss_thermocouple = readmatrix('W_emittance_CRC2600K.csv');
emiss_thermocouple = interp1(emiss_thermocouple(:,1),emiss_thermocouple(:,2),x,'linear','extrap');

TCJ = 2.5e-3; % << Cold junction factor, based on heat transport simulation of thermocouple wire
T_therm = interp2(V_lookup,a_lookup,T_lookup,V_smooth,TCJ);
t_spec = [D.t];

%% Select a subset of points to use for fitting
clear I
I_therm = [900:30:7043  21480:30:22450  31623:1:31632 31633:2:31653 31656:5:31688 31695:20:31900 31950:100:35000];
I_therm = I_therm(1:2:271);
for i=1:numel(I_therm)
    I(i) = find(t_spec >= t_therm(I_therm(i)),1);
end
laserPower = T_therm * 0.115/1400;

%% Initialize model object and populate fields
C = Spec_Cal_linear();
C.x = x;
C.D = D(I);
C.L = laserPower(I);
C.dataMask = ones(size(C.x));

% Background effects:

% Normally we'd use C.ComputeDark() but it seems there is a depression in ADC voltage at the highest refresh rate for this spectrometer, as well as an odd depression at the two ends that doesn't scale linearly.
% Instead, we'll use the dark signal directly captured at the relevant refresh rate without working to distinguish ADC offset vs dark current
itime = C.D(1).itime; % 10 ms
dark = load('spectrometer\Spectra_dark.mat','D');
dark = dark.D([dark.D.itime]==itime);
dark = mean([dark.counts],2);
dark = movmean(dark,35);

C.ADCoffset = 2430;
C.darkCurrent = (dark - C.ADCoffset)./itime;
C.laserCurrent = zeros(size(C.x)); % Laser was negligible for this run
C.doFitLaser = false;

% Calibration-specific things:
C.Ttrue = T_therm(I_therm);
C.EmissTrue = emiss_thermocouple;
C.Iassume = 65; % A point in the ramp that we didn't saturate. We'll treat this as having emissivity EmissTrue

% Choose parameters to be fit
C.seedAppend('Atarget'   , 0.4e+0  ,  1.0e-5, 1.0e+5);
C.seedAppend('BoxFactor' , 1.8e-3  ,  0.0e+0, 5.0e-2);
C.seedAppend('Bintercept',-4.0e-4  , -2.0e-2, 2.0e-2);
C.seedAppend('Bslope'    , 5.0e-8  , -1.0e+0, 1.0e+0);

%% Compute
C.Initialize();
C.Iterate(150);

C.Visualize([1 numel(I)]); % Check quality of fit for low and high temperatures
C.ModelEmiss(); figure; hold on; plot(C.EmissTrue); plot(C.Emiss(:,C.Iassume)) % Look at linear emissivity vs assumed emissivity
figure; plot(C.EmissA) % Look at variation in FOV between captures (e.g. sample drift, emissivity change)

%% Create final TSE curve
A = C.TSE.*C.FOV;
C.FOV = max(A);
C.TSE = A./C.FOV;

% Averaging curves for noise reduction:
C.ModelEmiss();
TSE = NaN([C.nx C.nd]);
for i = 1:C.nd
    TSE(:,i) = C.InvertTSE(i)./C.Emiss(:,i);
end
%figure; hold on; for i = 1:C.nd; plot(C.x,TSE(:,i)); end
% Now remove any with NaN or large outliers:
mask = false([1 C.nd]);
for i = 1:C.nd
    mask(i) = any(isnan(TSE(:,i)));
end
TSE = TSE(:,~mask);
%figure; hold on; for i = 1:size(TSE,2); plot(C.x,TSE(:,i)); end
mask = false([1 size(TSE,2)]);
temp = median(TSE,2);
for i = 1:numel(mask)
    mask(i) = any( abs(TSE(:,i)-temp) > 0.1  ) ;
end
TSE = TSE(:,~mask);
%figure; hold on; for i = 1:size(TSE,2); plot(C.x,TSE(:,i)); end
TSE_avg = mean(TSE,2);
TSE_avg = TSE_avg./max(TSE_avg);

C_cal = copy(C);
C_cal.TSE = TSE_avg;
C_cal.PlotHandles = []; % Remove some unnecessary data before saving
C_cal.DatasetLabel = 'Type C (tungsten) thermocouple calibration using linear emissivity model. TCJ = 2.5e-3, no laser fitting';
fname = sprintf('SpecModel_OceanOptics_TungCal_%16s.mat',datestr(clock,'YYYY_mm_dd_HH_MM'));
save(fname,'C_cal'); % Once saved, move this to your calibrations folder

%% Fit full dataset using the newly-made calibration
clear C
C = Spec_LinEmiss_set(C_cal);
C.Parallel = true;
%{
C.D = D(I); C.L = laserPower(I);
C.seedAppend('Atarget'   , 0.4 ,  1e-5,    1e5);
C.seedAppend('Bintercept',-4e-4, -20e-3, 20e-3);
C.seedAppend('Bslope', 5e-8,  -1, 1);
C.Parallel = true;
C.Initialize();
C.Iterate(150);
%}

% Apply model with best fit parameters
C.D = D; C.L = laserPower;
C.InitializeModel();
C.Bintercept = C_cal.Bintercept;
C.Bslope = C_cal.Bslope;
C.Atarget = C_cal.Atarget;
C.RunModel();

C_full = copy(C);
C_full.PlotHandles = [];
save('Results.mat','C_full');

figure; plot(t_spec,C.EmissA)
for i=1:numel(t_spec)
    I_therm(i) = find(t_therm >= t_spec(i),1);
end

H=figure; hold on
lw=1.5;
plot(t_therm,T_therm,'k','LineWidth',lw);
plot(t_spec(t_spec<310) ,C.T(t_spec<310) ,'r','LineWidth',lw);
set(gca,'FontSize',12)
xlabel('time (s)')
ylabel('Temperature (°C)')
box on
% Full:
xlim([-10 360]); ylim([0 2000]); legend({'Thermocouple','Pyrometry'},'Location','southwest')
% Ramp region:
%xlim([-10 50]); ylim([1350 1900]); legend({'Thermocouple','Pyrometry'},'Location','northwest')
%printpdf(H,'Temperature Fit');

% Overall temperature deiscrepancy:
figure; plot(t_spec,T_therm(I_therm)-C.T)
xlim([-10 310])
xlabel('time (s)'); ylabel('Temeprature discrepancy (°C)')
% As a fractionm, this discrepancy never exceeds 2%