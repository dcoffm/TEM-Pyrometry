
function [time,laserPower,laserOn,laserConn,camMode,camState] = readLaserFile(fname)
    
    datatypes = {'uint32',  % time
                 'uint16',  % laser state
                 '2*uint16' % mirror cam X/Y, or exposure/mean counts
    };

    datasizes = [4,  
                 2,
                 4,
    ];
    

    temp  = dir(fname);
    blocksize = sum(datasizes);
    N = temp.bytes/blocksize;
    fid = fopen(fname);
        
    i=1;
    time = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    fseek(fid,sum(datasizes(1:i)),'bof');
    
    i=2;
    laserState = fread(fid,[N 1],datatypes{i},blocksize-datasizes(i));
    fseek(fid,sum(datasizes(1:i)),'bof');
    
    i=3;
    camState = fread(fid,[2 N],datatypes{i},blocksize-datasizes(i));
    fseek(fid,sum(datasizes(1:i)),'bof');
    
    fclose(fid);

    camMode    = bitget(laserState,13,'uint16');
    laserConn  = bitget(laserState,12,'uint16');
    laserOn    = bitget(laserState,11,'uint16');
    
    % Laser power is the lower 10 bits of this state
    laserPower = bitset(laserState,11,0,'uint16');
    laserPower = bitset(laserPower,12,0,'uint16');
    laserPower = bitset(laserPower,13,0,'uint16');
    
    camState = camState';
    time = time/1000; % Move units to seconds
end