
load SpecModel_OceanOptics_TungCal_2024_03_25_19_23.mat
load InputData.mat
load diffraction\refined_peaks.mat

% Evaluate dark current:
mask = t_spec < 1000 & laserPower_spec==0;
dark = [D(mask).counts]; dark = reshape(dark,[1036 numel(dark)/1036])';
ADC_offset = 2466.0; % Evaluated manually before starting; automate this later...
dark = dark - ADC_offset;
dark = dark./[D(mask).itime]';
dark = mean(dark,1);
laserCurrent = 800 * ones(size(C_cal.x));

% It seems that there is a change in adc offset or laser factor between beginning and end, about 50 counts
mask = t_spec > 6000;
for i = 1:numel(D)
    if mask(i)
        D(i).counts = D(i).counts - 50;
    end
end

% Choose spectra for initial fitting process
I = 2497:2497+34;

% Set up the model
C = Spec_LinEmiss_set(C_cal);
C.ADCoffset = ADC_offset;
C.darkCurrent = dark';
C.laserCurrent = laserCurrent;
C.laserScale = 1;
C.D = D(I);
C.L = laserPower_spec(I);
C.Bslope = 0;

C.seedAppend('Atarget'      , 0.055 ,  0.01,    3);
C.seedAppend('BoxFactor'    , 1.8e-2,     0, 5e-2);
C.seedAppend('Bintercept'   ,-2e-3  ,-20e-3,20e-3);
%C.seedAppend('Bslope'       , 8e-5  ,    -1,    1);

C.Initialize();
C.Iterate(60);
C.Iterate(60);
C.Visualize([1 numel(I)]);
figure; hold on; plot(t_spec(I),C.T,'.'); xlabel('time (s)'); ylabel('Temperature (°C)'); box on
figure; plot(C.T,C.EmissA)

% Ok, looks reasonable; now apply this to even lower temperature data...
I_DPs = [6:9 11:20 23]; % Software used for recording info includes approximate timestamps for diffraction patterns
t_DPs = [micrographs(I_DPs).time];
clear I
for i=1:numel(t_DPs)
    I(i) = find(t_spec>=t_DPs(i),1);
end
C.D = D(I);
C.L = laserPower_spec(I);
C.InitializeModel();
C.RunModel();

figure; plot(t_spec(I),C.T,'.')
figure; plot(laserPower_spec(I),C.T,'.'); xlabel('Normalized Laser Power'); ylabel('Temperature (°C)')

a1 = [DP_dat.a1];
a2 = [DP_dat.a2];
A = [DP_dat.laserPower];

g1 = (a1-a1(1))./a1(1); % Reciprocal strain
g2 = (a2-a2(1))./a2(1);
s1 = -g1./(1+g1); % Real space strain
s2 = -g2./(1+g2);
strain = (s1+s2)/2*100;

% 5:19 from DP_dat
figure; plot(strain(5:19),C.T,'ko'); xlabel('Strain (%)'); ylabel('Temperature (°C)'); set(gca,'FontSize',12)
xlim([0.4 0.7])

% Use only the last bit where temperature estimate is confident for thermal expansion coefficient:
X = strain(5+6:19); Y = C.T(1+6:end);
p = polyfit(X,Y,1);
hold on; plot([0.4 0.7],[0.4 0.7]*p(1)+p(2),'r--')
alpha = 1/p(1)/100
text(gca,0.05,0.95,'\alpha = 11.8x10^-^6 °C^-^1','Units','normalized','VerticalAlignment','top');
printpdf(gcf,'Thermal Expansion');
% Reading numbers from this plot, we can check coefficient of thermal expansion:
%dT = 840.723-626.415; % Read these manually
%dS = (0.67722-0.421843)/100;
%alpha = dS/dT  % 1.2e-05 per kelvin -> a reasonable value

% For fun, let's run the algorithm on all the data

C.D = D;
C.L = laserPower_spec;
C.InitializeModel();
C.RunModel();
figure; plot(t_spec,C.T,'.')
figure; plot(laserPower_spec*100,C.T,'.')
