function notes = readNotes(fname)

% Open the text file
txt = fileread(fname);
I = regexp(txt,'NEWNOTE: ');

notes = struct('time',NaN,'time_hm',{},'type',{},'contents',{});
TEM = struct('X',NaN,'Y',NaN,'Z',NaN,'TiltX',NaN,'TiltY',NaN,'Focus',NaN,'IGP',NaN);

I = [I numel(txt)+1];
for i = 1:numel(I)-1
    
    str = txt(I(i):I(i+1)-1);
    [~,str] = strtok(str,' ');
    [type,str] = strtok(str);
    j = regexp(str,'[0-9]'); str = str(j(1):end);
    [time_formatted,str] = strtok(str,' \t');
    [time_ms,str] = strtok(str,' )');
    time_ms = str2double(time_ms(2:end));
    j = regexp(str,'\n'); str = str(j(1)+1:j(end-2)-2);
    
    notes(i).time = time_ms/1000;
    notes(i).time_hm = time_formatted;
    notes(i).type = type;
    if(strcmp(type,'TEMINFO'))
        j = regexp(str,':|\n');
        TEM.X = str2double(str(j(1)+1:j(2)));
        TEM.Y = str2double(str(j(3)+1:j(4)));
        TEM.Z = str2double(str(j(5)+1:j(6)));
        TEM.TiltX = str2double(str(j(7)+1:j(8)));
        TEM.TiltY = str2double(str(j(9)+1:j(10)));
        TEM.Focus = str2double(str(j(11)+1:j(12)));
        TEM.IGP = str2double(str(j(13)+1:end));
        notes(i).contents = TEM;
    else
        notes(i).contents = str;
    end
end

end