% For the UIUC spectrometer + capture program
function [data,x] = readSpectra(fname)
   
    datatypes = {'uint32',  % time
                 'uint32',  % itime
                 'double',  % TEC
                 '1044*uint16' % Spectrum
    };        M = 1044;

    datasizes = [4,  
                 4,
                 8,
                 2*M,
    ];
    
    temp  = dir(fname);
    blocksize = sum(datasizes);
    N = temp.bytes/blocksize;
    
    fid = fopen(fname);
    i=1; time   = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i)); fseek(fid,sum(datasizes(1:i)),'bof');
    i=2; itime  = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i)); fseek(fid,sum(datasizes(1:i)),'bof');
    i=3; TEC    = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i)); fseek(fid,sum(datasizes(1:i)),'bof');
    i=4; counts = fread(fid,[M N],datatypes{i},blocksize-datasizes(i));
    fclose(fid);
    
    % Based on stored (old...) calibration constants:
    c0 =  613.992879;
    c1 =  3.927170e-1;
    c2 = -3.391857e-5;
    c3 =  5.375187e-9;

    p = (0:1043) -10; % The 10 is because there is some glitch with spectrasuite software?
    x = c0 + c1*p + c2*p.^2 + c3*p.^3;
    
    % Trim the crappy pixels off of each end
    %mask = 1:1044;
    mask = 5:1040;
    counts = counts(mask,:);
    x = x(mask);
    
    d = SpectrumCapture();
    d.counts = NaN([numel(x) 1]);
    d.EMG = 1;
    data = repmat(d,1,N);
    
    for i = 1:N
        d.t = time(i)/1000; % Move time unit to seconds
        d.itime = itime(i)/1e6;
        d.TEC = TEC(i);
        d.counts = counts(:,i);
        d.SumCounts();
        data(i) = copy(d);
    end
    
    %in1 = num2cell(time);
    %stemp = num2cell(spectra,1)';
    %data = struct('time',num2cell(time),'itime',num2cell(itime),'TEC',num2cell(TEC),'EMG',num2cell(EMG),'ADC_offset',num2cell(ADC_offset),'counts',stemp);
end