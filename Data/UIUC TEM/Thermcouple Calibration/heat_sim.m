
% Explore likely cold junction temperatures (TCJ factor in calibration model)
% based on mixed conductive/radiative transport

eps_tung = 0.38; % Approximate emissivity of tungsten
SBoltz = 5.6703e-8; % Stephan-Boltzmann constant 
T0 = 298;    % Room temperature
r = 3.8e-5;  % Wire diameter
L = 22.5e-3; % Wire length
k = 120; % Tungsten thermal conductivity, W/m.K 
mu = 2*eps_tung*SBoltz/r; % For readability

%SI = 115:4:139;
SI = [115 139];
Ttips = 1500 + 18*(SI-115); % Ballpark tip temperatures

for J = 1:numel(SI)

Ttip = Ttips(J) + 273.15;
Plaser = 50 * SI2pow(SI(J)) * eps_tung * 0.5; % Power being added to the system by the laser
    % This considers power setting & reflectivity, and a factor of 0.5 for flow thru two wires
   
dy0 = -Plaser/k/pi/r^2; % The boundary condition so that Plaser is conducted into the system

% bounds on dy0:
% - final temperature must be greater than room temp (298 K)
% - final derivative must be less than zero

fudge = linspace(0.5,0.6,1000); % Adjustment to input power (since exact optical conditions are unknown)
valid = false(size(fudge));
T_base = NaN(size(valid));
dT_base = NaN(size(valid));
for i = 1:numel(fudge)
    warning ('off','all');
    [x,T] = ode45(@(t,y) odefun_rad(t,y,T0,k,mu),[0 L],[Ttip; dy0*fudge(i)]);
    warning ('on','all');
    T_base(i) = T(end,1);
    dT_base(i) = T(end,2);
    valid(i) = (dT_base(i)<0) && (T_base(i)>T0);
end
xl = [fudge(find(valid,1)) fudge(find(valid,1,'last'))]; 
TCJ = (T_base-T0)/(Ttip-T0);
Pbase = -(dT_base*k*pi*r^2);
Rbase = (T_base-T0)./Pbase;


figure; 
subplot(2,1,1)
%plot(fudge(valid),T_base(valid)); xlabel('fudge'); ylabel('Temperature (K) at base'); xlim(xl)
plot(fudge(valid),TCJ(valid)); xlabel('fudge'); ylabel('TCJ factor'); xlim(xl); title(sprintf('SI %u',SI(J)));
subplot(2,1,2)
%plot(fudge(valid),-dT_base(valid)*k*pi*r^2); xlabel('fudge'); ylabel('Power conduction at base (watts)'); xlim(xl)
plot(fudge(valid),Rbase(valid)); xlabel('fudge'); ylabel('Thermal impedance of holder (K/W)'); xlim(xl)

if valid(1);fprintf('\nExtend lower range on SI %u',SI(J)); end
if valid(end);fprintf('\nExtend upper range on SI %u',SI(J)); end

end

%figure; plot(x,T(:,1)); xlabel('meters'); ylabel('Kelvin'); %ylim([0 2000])

function dydt = odefun_rad(t,y,T0,k,mu)
    dydt = [y(2); (mu/k*y(1)^4 - mu/k*T0^4)];
end