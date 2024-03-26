
% Line up times between spectral/thermocouple data, and compute temperature readings from thermocouple voltage
global T_typec V_typec
load('potentiostat/thermocouple type-c.mat','T_typec','V_typec');
fname = 'potentiostat/continuous2_C01.mpt';
temp = readmatrix(fname,'FileType','text');
V = temp(:,4)*1000; % millivolts

% Line up the times: 
%{
load('spectrometer/Spectra_cont2.mat','D','x')
t_spec = [D.t];
t_therm = temp(:,3);

t1_spec = 9.73; % Use two recognizable features
t2_spec = 316.45;
t1_therm = 9.50; 
t2_therm = 316.21;
scale = (t2_therm-t1_therm)/(t2_spec-t1_spec); % should be close to 1

t_therm = t_therm-t1_therm;
t_spec = (t_spec-t1_spec).*scale;

figure; hold on; ylim([0 1])
M = [D.counts];
plot(t_spec,M(200,:)./max(M(200,:)),'r')
plot(t_therm,V./max(V),'b')

for i = 1:numel(D)
    D(i).t = t_spec(i);
end
save('spectrometer/Spectra_cont2.mat','D','x')
%}

V_smooth = smooth(V,100,'rloess');
V_smooth(31566:31703) = V(31566:31703); % avoid smoothing around precipetous drop
T_therm = interp1(V_typec,T_typec,V,'linear','extrap'); % The simple conversion (cold junction = room temp)
T_therm_smooth = interp1(V_typec,T_typec,V_smooth,'linear','extrap');
save('potentiostat/Thermocouple_cont2.mat','t_therm','V','V_smooth');


%% Accounting for cold junction effects: create a pre-computed table
Troom = 22.5;
vmax = 37.1;
amax = 0.3;

[V_lookup,a_lookup] = meshgrid(0:0.01:vmax,0:0.01:amax);
T_lookup = NaN(size(V_lookup));
for i = 1:size(a_lookup,1)
for j = 1:size(a_lookup,2)
    T_lookup(i,j) = TCtemp(V_lookup(i,j),Troom,a_lookup(i,j));
end
end
save('potentiostat/TC_lookup_22.5C.mat','V_lookup','a_lookup','T_lookup');

%% Helper functions
function Thj = TCtemp(Vobs,Troom,a)
% Calculates hot junction temperature Thj from an observed thermocouple (mili)voltage Vobs,
% assuming that the cold junction temperature is proporitonal to hot junction temperature by factor a:
% Tcj = Troom + a*(Thj - Troom)

% Approach:
% Choose a Thj
% get implied Tcj by proportionality and by Vobs
% compare the two
% use difference to iterate towards a self-consistent value

% Initial guess using a linear voltage relationship:
Thj = Troom + Vobs./(37.107/2320)./(1-a);

% Bisection root finding method to optimize:
for i = 1:numel(Thj)
    T = Thj(i);
    V = Vobs(i);
    
    TU = T + 200; % Our guess should not be wrong by more than 180
    TL = T - 200; 
    fU = geterr_signed(TU,V,Troom,a);
    fL = geterr_signed(TL,V,Troom,a);
    T = TL;
    repmax = 10;
    for rep = 1:repmax
        l=1;
        T = (TL+TU)/2; % New test value
        fT = geterr_signed(T,V,Troom,a);
        if fL*fU >0         % They are currently the same sign; replace larger one w/ new point
            if abs(fU)>abs(fL); l=~l; end
        else                % They are opposite signs; replace point with same sign
            if fT*fU > 0; l=~l; end
        end
        if l;  TL = T; fL = fT;
        else   TU = T; fU = fT; end
    end

    Thj(i) = T;
end
end

function out = geterr_signed(Th,Vobs,Troom,a)
    global T_typec V_typec
    Tc_a = Troom + a*(Th - Troom);
    Vh = interp1(T_typec,V_typec,Th,'linear','extrap');
    Vc = Vh-Vobs;
    Tc_b = interp1(V_typec,T_typec,Vc,'linear','extrap');
    out = Tc_a - Tc_b;
end
