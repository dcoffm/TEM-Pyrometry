function this = SpectrometerModel(this,I)
% Computes expected ADU counts from given spectrometer, sample, and laser conditions

% Constants:
k = 1.38064852e-23;  % J/K
c = 299792458;       % m/s
h = 6.62607e-34;     % J.s
hck = h*c/k;

% Setup
T = this.T + 273.15; % Convert to Kelvin
x = this.x * 1e-9; % Convert to meters
dx = gradient(x);

for i = I
    
    d = this.D(i);
    
    L = this.laserCurrent * this.L(i) * this.laserScale;

    % Computation
    B = (2*c./x.^4)./(exp(hck./x./T(i))-1);
    N = B.*this.Emiss(:,i).*d.itime.*this.TSE*this.FOV.*dx;
    N = N + this.BoxFactor*mean(N);
    N = N + d.itime*(this.darkCurrent + L);

    % Original:
    N = this.ADCoffset + N*d.ADCsens*d.EMG;   % (A)

    % EMCCD + baseline clamp ?
    %N = (Spec.ADC_offset + N*Spec.ADC_sens).*Spec.EMG; % (B)
    % From examination of signal produced after switching EMG setting, it seems EMG is applied AFTER offset.
    % In other words, the output counts are all proportionally scaled including the baseline... 
    % weird since that's not how I understand ADC to work. Unless the "baseline clamp" feature also adjusts offset 

    %N = (Spec.ADC_offset + N)*Spec.ADC_sens*Spec.EMG; % (C)
    
    this.ModelCounts(:,i) = N;
    
end
end