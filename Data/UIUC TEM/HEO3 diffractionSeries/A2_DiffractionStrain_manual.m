
% Data structure for frames
dat = struct('fname','','pdist',0,'lolog',0,'hilog',0,'x0',0,'x1',0,'x2',0,'y0',0,'y1',0,'y2',0,'a1',0,'a2',0,'laserPower',0);

% What file numbers to include in your range (e.g. img_070, img_095)
% In my case the file name also serves as a stand-in for laser power setting used to capture the image
A = [0 70:5:95 98:2:122 123:129];

H=figure;
for i = 1:numel(DP_files)
    
    dat(i).fname = sprintf('input/si%03u.tif',A(i));  % Modify this string pattern to match your file naming scheme
    dat(i).pdist = 20.11/2004;  % inverse nm per pixel, **find this using imagej on the dm3 file**
    dat(i).laserPower = SI2pow(A(i)); % if relevant
    
    % Normalization range for floating point image intensity.
    % For floating point data I found it's easiest to work in log(intensity)
    % Choose these values by showing an image with imshow() and sampling some low and high spots
    dat(i).lolog =  6; % log value of background level (will go to zero)
    dat(i).hilog = 10; % log value of peak level (will go to one)
    
    img0 = imread(dat(i).fname);
    img = real(log(img0));  
    img = img-dat(i).lolog;
    img = img./(dat(i).hilog-dat(i).lolog);
    imshow(img)
    
    % Manually identifying approximte peak positions
    % - Draw two lines in two independent directions of your lattice.
    % - Since the direct beam is blocked, instead have your first vector span from -1 to 1 index
    % - draw your second vector from the same starting point but in the second direction
    % - Be consistent about which spot you choose for each frame
    % - You don't have to be super accurate, just get it close enough so that the automated process can do its work
    title([dat(i).fname '  -  vector 1'])
    drawnow
    line = imline;
    P = line.getPosition()'; 
    dat(i).x0 = round(P(1));
    dat(i).y0 = round(P(2));
    dat(i).x1 = round(P(3));
    dat(i).y1 = round(P(4));

    title([dat(i).fname '  -  vector 2'])
    drawnow
    line = imline;
    P = line.getPosition()';
    dat(i).x2 = round(P(3));
    dat(i).y2 = round(P(4));
end
% Save these points to disk and use them as input to the refinement script
DP_dat = dat;
save('diffraction/manual_peaks.mat','DP_dat')