
function [data] = readSpectra_SNL(fname)
    % Data format exported by the SNL TEMLaser program for spectral data
    load SpecCalibrations.mat
    
    datatypes = {'uint32',  % time
        
                 % begin cMode struct
                 'uint8',   % amps & shift speeds (+3 more bytes?)
                 'uint8',   % EMG  (+3 preceeding bytes)
                 'float',   % Exposure Time
                 'float',   % median filter
                 'double',  % ADC_offset
                 'double',  % Dark noise
                 'int',     % crop (+4 more bytes?)
                 % end  cMode struct
                 
                 'int',  % TEC reading
                 '1600*uint16' % Spectrum, ADC counts
                 
    };        M = 1600;
    
    datasizes = [4,  
                 4,
                 4,
                 4,
                 4,
                 8,
                 8,
                 8,
                 4,
                 2*M,
    ];    

    temp  = dir(fname);
    blocksize_sum = sum(datasizes); % need to figure out which field sizes are wrong
    blocksize = 3248; % Found empirically
    N = temp.bytes/blocksize;
    
    fid = fopen(fname);
        
    i=1;
    time = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    fseek(fid,sum(datasizes(1:i)),'bof');
    
    i=2;
    ampsNspeeds = fread(fid,[N 1],[datatypes{i} '=>' datatypes{i}],blocksize-datasizes(i)+3);
    % apparently it still takes up 4 bytes even though all the data is in one... so much for bit fielding
    
    ampMode = bitget(ampsNspeeds,1,'uint8');
    
    HSS1 = bitget(ampsNspeeds,2,'uint8');
    HSS2 = bitget(ampsNspeeds,3,'uint8');
    HSS_index = HSS2*2 + HSS1*1 + 1; % turns into indices: 1,2,3 for 3MHz, 1 MHz, 0.05 MHz
    HSS_vals = [3e6 1e6 0.05e6];
    HSS = HSS_vals(HSS_index)';
    
    VSS1 = bitget(ampsNspeeds,4,'uint8');
    VSS2 = bitget(ampsNspeeds,5,'uint8');
    VSS3 = bitget(ampsNspeeds,6,'uint8');
    VSS_index = VSS3*4 + VSS2*2 + VSS1*1 + 1;
    VSS_vals = [4.88 9.68 19.28 38.47 57.68];
    VSS = VSS_vals(VSS_index)';
    
    PAG1 = bitget(ampsNspeeds,7,'uint8');
    PAG2 = bitget(ampsNspeeds,8,'uint8');
    PAG_index = PAG2*2 + PAG1*1 + 1;
    PAG_vals = [1 2 4];
    PAG = PAG_vals(PAG_index)';
    
    clear PAG1 PAG2 HSS1 HSS2 VSS1 VSS2 VSS3 VSS_vals HSS_vals PAG_vals fname
    
    fseek(fid,sum(datasizes(1:i)),'bof'); % it occupies 4 bytes but only uses the 4th byte to store a uint8 value
    i=3;
    EMG_index = fread(fid,[N 1],'uint8=>uint16',blocksize-1);
    
    %fid_emg = fopen('EMCCDgain.cal','r');
    %EMG_vals = fread(fid_emg,256,'double');
    %fclose(fid_emg); % This is now loaded in by SpecCalibrations.mat
    EMG = EMGs(EMG_index+1)';
    
    fseek(fid,sum(datasizes(1:i)),'bof');
    
    i=4;
    itime = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    fseek(fid,sum(datasizes(1:i)),'bof');
    
    i=5;
    medFilt = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    fseek(fid,sum(datasizes(1:i)),'bof');
    
    i=6;
    ADC_offset = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    fseek(fid,sum(datasizes(1:i)),'bof');
    
    i=7;
    darknoise = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    fseek(fid,sum(datasizes(1:i)),'bof');
    
    i=8;
    crop = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i)+4); % Not sure why there's an extra 4 bytes at the end of struct?
    fseek(fid,sum(datasizes(1:i)),'bof');
    
    i=9;
    TEC = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    fseek(fid,sum(datasizes(1:i)),'bof');
       
    i=10;
    spectra = fread(fid,[M N],datatypes{i},blocksize-datasizes(i));
    
    fclose(fid);    
    
    spectra = spectra';
    spectra = fliplr(spectra);
    
    %{
    % Based on stored (old...) calibration constants:
    c0 =  613.992879;
    c1 =  3.927170e-1;
    c2 = -3.391857e-5;
    c3 =  5.375187e-9;

    p = (0:1043) -10; % The 10 is because there is some glitch with spctrasuite software?
    x = c0 + c1*p + c2*p.^2 + c3*p.^3;
    
    % Trim the crappy pixels off of each end
    %mask = 1:1044;  
    %mask = 5:1038; 
    mask = 5:1037;
    spectra = spectra(:,mask);
    x = x(mask);
    %}
    
    data = struct('time_ms',num2cell(time),'time',num2cell(time/1000),'itime',num2cell(itime),'AmpMode',num2cell(ampMode),'PAG_index',num2cell(PAG_index),'PAG',num2cell(PAG),'EMG_index',num2cell(EMG_index),'EMG',num2cell(EMG),'HSS_index',num2cell(HSS_index),'HSS',num2cell(HSS),'VSS_index',num2cell(VSS_index),'VSS',num2cell(VSS),'medianFilter',num2cell(medFilt),'ADC_offset',num2cell(ADC_offset),'counts',num2cell(spectra,2),'photoflux',num2cell(NaN(size(spectra)),2));
    
end