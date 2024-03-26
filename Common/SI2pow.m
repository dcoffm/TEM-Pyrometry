function out = SI2pow(varargin)
% For an power setting (SI) value between 0 and 1000
% gives the laser output, either normalized or in watts (2nd argument for system rated power)
% (This is for the SPI G4 IR laser syststem, empirically derived from measured outputs)

SI = varargin{1};
powerScale = 1;
if nargin==2
    powerScale = varargin{2};
end

x0 = 91.7879;
y0 = 8.6135e-3 / 1.1661;
m  = 1.2841e-3 / 1.1661;
d  = 21.4283;

x = SI-x0;
out = (y0 + m*x.*(atan(x./d)/pi + 1/2) ) * powerScale;
end