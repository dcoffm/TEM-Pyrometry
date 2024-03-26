function TSE = InvertTSE(this,I)
% Derive a TSE using spectrum at index I an assumed temperature T

k = 1.38064852e-23;  % J/K
c = 299792458;       % m/s
h = 6.62607e-34;     % J.s

T = this.Ttrue(I) + 273.15; % Convert to Kelvin
x = this.x * 1e-9; % Convert to meters
L = this.laserCurrent * this.L(I) * this.laserScale; % reference curve * power fraction * scaling parameter
D = this.D(I);

% Computation
B = (2*c./x.^4)./(exp(h*c/k./x./T)-1);
n = (D.counts - this.ADCoffset)./(D.ADCsens*D.EMG);
n = n - D.itime*(this.darkCurrent + L);
n_prebox = n;

for i = 1:5
    n = n_prebox - this.BoxFactor*mean(n,'omitnan');
end

TSE = n./(B.*D.itime.*this.FOV.*gradient(x));
end