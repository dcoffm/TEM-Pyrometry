
notes_all = readNotes('notes.txt');
[D,x] = readSpectra('spectra');
t_spec = [D.t];
[t_laser,laserPowerSetting,laserOn,laserConn,camMode,camState] = readLaserFile('laserstatus');

% Remove duplicate time points (should be fixed in future versions of the program)
[t_laser,ia] = unique(t_laser,'first'); 
laserPowerSetting = laserPowerSetting(ia);
laserOn = laserOn(ia);
laserConn = laserConn(ia);
camMode = camMode(ia);
camState = camState(ia,1:2);

% Convert power setting to estimated true power output (0 to 1)
laserPower = SI2pow(laserPowerSetting).*laserOn;

mask = false(size(notes_all));
for i = 1:numel(notes_all)
    if strcmp(notes_all(i).type,'MICROGRAPH')
        mask(i) = 1;
    end
end
micrographs = notes_all(mask);

laserPower_spec = interp1(t_laser,laserPower,t_spec);

save('InputData.mat','D','t_laser','t_spec','laserPower','laserPower_spec','notes_all','micrographs');