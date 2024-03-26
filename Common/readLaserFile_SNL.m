
function [data] = readLaserFile_SNL(fname)
    
    datatypes = {'uint32',  % time
                 'uint8',   % control signals
                 'uint16',  % laserPower (active)
                 'uint16',  % laserPower (simmer)
                 'uint16',  % laserDutyFactor
                 'uint32',  % PRF
                 'double',  % Temperature (laser)
                 'double',  % Temperature (Beam deliver optic)
                 'double',  % Current (pre-amplifier diode)
                 'double',  % Current (Power amplifier diode)
                 'double',  % Voltage (logic power supply)
                 'double',  % Voltage (Diode power supply)
                 '2*uint16' % mirror cam X/Y, or exposure/mean counts
    };

    datasizes = [4,  
                 2,
                 2,
                 2,
                 2,
                 8,
                 8,
                 8,
                 8,
                 8,
                 8,
                 8,
                 4,
    ];
    

    temp  = dir(fname);
    blocksize_sum = sum(datasizes);
    %blocksize = 72;
    blocksize = 72;
    N = temp.bytes/blocksize;
    fid = fopen(fname);
        
    i=1;
    time = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    
    fseek(fid,sum(datasizes(1:i)),'bof');    i=2;    
    laserState = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i)+1);
    laserConnected = logical(bitget(laserState,1,'uint8'));
    laserEnabled   = logical(bitget(laserState,2,'uint8'));
    laserPilot     = logical(bitget(laserState,3,'uint8'));
    laserCW        = logical(bitget(laserState,4,'uint8'));
    laserActive    = logical(bitget(laserState,5,'uint8'));
    alignmentcam   = logical(bitget(laserState,6,'uint8'));
    
    
    fseek(fid,sum(datasizes(1:i)),'bof');    i=3;
    laserPowerActive = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    
    fseek(fid,sum(datasizes(1:i)),'bof');    i=4;
    laserPowerSimmer = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    
    fseek(fid,sum(datasizes(1:i)),'bof');    i=5;
    laserDutyFactor  = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    
    fseek(fid,sum(datasizes(1:i)),'bof');    i=6;
    laserPulseRateFrq= fread(fid,[N 1],datatypes{i},blocksize-datasizes(i)+4);
    
    fseek(fid,sum(datasizes(1:i)),'bof');    i=7;
    laserTempMain    = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    
    fseek(fid,sum(datasizes(1:i)),'bof');    i=8;
    laserTempBDO     = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    
    fseek(fid,sum(datasizes(1:i)),'bof');    i=9;
    laserCurrentPream= fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    
    fseek(fid,sum(datasizes(1:i)),'bof');    i=10;
    laserCurrentPower= fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    
    fseek(fid,sum(datasizes(1:i)),'bof');    i=11;
    laserVoltageLogic= fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    
    fseek(fid,sum(datasizes(1:i)),'bof');    i=12;
    laserVoltagePower= fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    
    fseek(fid,sum(datasizes(1:i)),'bof');    i=13;
    camState = fread(fid,[2 N],datatypes{i},blocksize-datasizes(i));
        
    fclose(fid);
    
    % An estimate of "real" normalized laser output considering enable
    % state, duty factor, and empirical setting<->power measurements
    laserOutput = laserEnabled .* SI2pow(laserPowerActive) .* laserDutyFactor/1000;

    data = struct('time_ms',num2cell(time),'time',num2cell(time/1000),'laserOutput',num2cell(laserOutput),'laserConnected',num2cell(laserConnected),'laserEnabled',num2cell(laserEnabled),'laserActive',num2cell(laserActive),'laserCW',num2cell(laserCW),'laserPilot',num2cell(laserPilot),'laserPowerActive',num2cell(laserPowerActive),'laserPowerSimmer',num2cell(laserPowerSimmer),'laserDutyFactor',num2cell(laserDutyFactor),'laserPulseRateFrq',num2cell(laserPulseRateFrq),'laserTempMain',num2cell(laserTempMain),'laserTempBDO',num2cell(laserTempBDO),'laserAmpsPreamp',num2cell(laserCurrentPream),'laserAmpsPower',num2cell(laserCurrentPower),'laserVoltageLogic',num2cell(laserVoltageLogic),'laserVoltagePower',num2cell(laserVoltagePower),'alignCamX',num2cell(camState(1,:)'),'alignCamY',num2cell(camState(2,:)'));
end