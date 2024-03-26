
H=figure;
load diffraction/manual_peaks.mat
for i = 1:numel(DP_dat)
    d = DP_dat(i); % to make code easier to read
    
    img0 = imread(d.fname);
    %img = real(log(img0));
    %img = img-d.lolog;
    %img = img./(d.hilog-d.lolog);
    img = double(img0)./255;

    % Some parameters that may be adjusted for this process
    thresh = 0.9;      % 1-thresh defines the fraction of brightest pixels that will be considered for spot centroid. Keep close to 1.
    r = 50;             % Size of the subimage considered for peak refinement. Should confortably contain the diffraction spot. 
    smooth = 3;         % Degree of gaussian smoothing do reduce image noise while fitting spot position
    prom = 0.08;        % Arbitrary parameter for determining how prominent a peak is
    
    % Refine the location of the manually identified peaks
    [img_, x0, y0] = subimg(img,d.x0,d.y0,r,smooth);
    P0 = getSpot(img_,thresh) + [x0;y0];
    %P0 = [x0;y0]; % I chose the actual central spot for manual vectors so my guess is still be best result for this spot since it is blocked
    [img_, x0, y0] = subimg(img,d.x1,d.y1,r,smooth);
    P1 = getSpot(img_,thresh) + [x0;y0];
    [img_, x0, y0] = subimg(img,d.x2,d.y2,r,smooth);
    P2 = getSpot(img_,thresh) + [x0;y0];
    
    % Initial reciprocal vectors
    DirectBeam = (P0 + P1)/2; % NOTE! because the direct beam is obscured, I chose to draw lines from -1 to 1 for first vector
    a1_ = (P1-DirectBeam);
    a2_ = (P2-P0);
    d.a1 = norm(a1_);
    d.a2 = norm(a2_);
    
    % Debug: show the fitted peak points
    %imshow(img); hold on;
    %scatter([P0(1) P1(1) P2(1)],[P0(2) P1(2) P2(2)],'r.')
    
    % Create a grid of possible lattice sites to check
    [X,Y] = meshgrid(-4:0.5:4,-1:0.5:1.5);
    mask = (X==0 & Y==0) | (X==-0.5 & Y==0); % Remove things partially overlapping the blocker
    X = X(~mask);
    Y = Y(~mask);
    
    % reciprical space coordinates
    x = X.*a1_(1) + Y.*a2_(1) + DirectBeam(1);
    y = X.*a1_(2) + Y.*a2_(2) + DirectBeam(2);
    
    % Now remove points that are irrelevant
    % - discard if they are outside the image
    % - discard if the peak is too weak to meaningfully locate
    
    x_true = NaN(size(x));
    y_true = NaN(size(y));
    sx = size(img,2);
    sy = size(img,1);
    for j = 1:numel(x)
        if x(j) > 0.5 && x(j) <= sx-0.5 && y(j) > 0.5 && y(j) <= sy-0.5  % point is within the image
            [img_, x0, y0] = subimg(img,x(j),y(j),r,smooth);
            c = img_(round(y(j))-y0,round(x(j))-x0); 
            if c- min(min(img_)) < prom || c<0 
                x(j) = NaN; y(j) = NaN;
            else
                % It looks like a good spot. Now fit the position within this sub-image
                P = getSpot(img_,thresh); % thresh is another arbitrary parameter
                P = P + [x0;y0];
                if norm(P - [x(j);y(j)]) > 10 % It probably messed up somehow
                    x(j) = NaN; y(j) = NaN;
                else % save the new position as a "true" position
                    x_true(j) = P(1);
                    y_true(j) = P(2);
                end
                
            end
        else
            x(j) = NaN; y(j) = NaN;
        end
    end
    
    % Debug: show extrapolated points vs fitted points
    %figure;imshow(img); hold on
    %scatter(x(:),y(:),'.r')
    %scatter(x_true(:),y_true(:),'.g')
    
    % Optimize origin point and reciprocal vectors to best fit true locations
    basis = [DirectBeam(1) DirectBeam(2) a1_(1) a1_(2) a2_(1) a2_(2)];
    for rep = 1:30
    for var = 1:numel(basis)
        delta = -10:0.1:10;
        bases = repmat(basis,[numel(delta),1]);
        bases(:,var) = bases(:,var)+delta';
        
        x_test = bases(:,1) + X(:)'.*bases(:,3) + Y(:)'.*bases(:,5);
        y_test = bases(:,2) + X(:)'.*bases(:,4) + Y(:)'.*bases(:,6);
        
        err = sum(sqrt((x_true(:)'-x_test).^2 + (y_true(:)'-y_test).^2),2,'omitnan');
        
        [~,I] = min(err);
        basis = bases(I,:);
    end
        x = basis(1) + X*basis(3) + Y*basis(5); 
        y = basis(2) + X*basis(4) + Y*basis(6);
        x(isnan(x_true)) = NaN;
        y(isnan(x_true)) = NaN;
        % Debug: show intermediate optimization steps
        %figure;imshow(img); hold on
        %scatter(x(:),y(:),'.r')
    end
    
    P0 = basis(1:2);
    a1_ = basis(3:4);
    a2_ = basis(5:6);
    d.a1 = norm(a1_);
    d.a2 = norm(a2_);
    DP_dat(i) = d; % save this back to the parent structure
    
    % Keep images aligned between frames for the video
    if i==1; P0_align = [basis(1);basis(2)]; end
    dx = P0_align(1)-basis(1);
    dy = P0_align(2)-basis(2);
    
    % Display the image with overlaid peaks (as extrapolated using basis vectors)
    % This shows the quality of the vector fitting process
    img(isinf(img)) = 0;
    img = imtranslate(img,[dx,dy]);
    imshow(img,'InitialMagnification',100); hold on
    scatter(x(:)+dx,y(:)+dy,'.r')
    
    
    % Label the figure
    %{-
    c = 1; % gray level for label text (1=white)
    scalebarexists = true;
    if scalebarexists
        text(75+dx,2594+dy,sprintf('a=%02.1f%%',d.laserPower*100),'FontSize',24,'FontWeight','bold','Color',[c c c])
    else
        text(85,1290,sprintf('a=%03u',d.laserPower),'FontSize',24,'FontWeight','bold','Color',[c c c]) % label for laser power

        px = 400; % approximately how many pixels we want for scalebar
        inm = d.pdist*px;
        mult = 5; % make scalebar in multiples of 5 inverse nanometers
        inm = round(inm/mult)*mult;
        px = round(inm/d.pdist);
        x1 = 85;
        x2 = 85+px;
        y1 = 1247;
        y2 = 1257;
        fill([x1,x2,x2,x1],[y1,y1,y2,y2],'white');
        text(85,1215,sprintf('%u 1/nm',inm),'FontSize',24,'FontWeight','bold','Color',[c c c])
    end
    %}
    drawnow
    
    doVid = false; % Set this to true once you're happy with the result to save the image sequence
	if doVid
        export_fig(gcf,['diffraction\' sprintf('img%03u.png',i)],'-native') % this function can be found on the Matlab exchange
        % Alternative: saveas(gcf,['output\' d.fname '.png'])
    else
        pause(0.05)
    end
end

a1 = [DP_dat.a1];
a2 = [DP_dat.a2];
A = [DP_dat.laserPower];

g1 = (a1-a1(1))./a1(1); % Reciprocal strain
g2 = (a2-a2(1))./a2(1);
s1 = -g1./(1+g1); % Real space strain
s2 = -g2./(1+g2);

%H = figure; plot(A*100,s1*100,'.'); hold on; plot(A*100,s2*100,'.');
%legend({'a','b'},'Location','northwest')

H = figure; plot(A*100,(s1+s2)/2*100,'.');
xlabel('Laser Power (%)')
ylabel('Lattice Strain (%)')
exportgraphics(H,'heating strain.pdf')

save('diffraction/refined_peaks.mat','DP_dat')

% To turn the image sequence into a video, use ffmpeg:
% > ffmpeg -framerate 6 -i 'img%03d.png' -c:v h264 -pix_fmt yuv420p -preset slow -crf 20 video.mp4

%
% Helper functions
%
function P = getSpot(img_,thresh)
    % find the center of the spot in this subimage by taking centroid of the brightest pixels
    temp = sort(img_(:));
    thresh = temp(round(numel(temp)*thresh));
    bw = img_>=thresh;
    b = bwboundaries(bw);
    temp = cellfun('size',b,1);
    [~,I] = max(temp);
    b = b{I};
    warning('off','MATLAB:polyshape:repairedBySimplify');
    pgon = polyshape(b(:,1),b(:,2));
    warning('on','MATLAB:polyshape:repairedBySimplify');
    [y,x] = centroid(pgon);
    P = [x;y];
    % debugging: visualize output
    %imshow(img_,'InitialMagnification',1000); hold on; scatter(x+1,y+1,10,'filled');
end

function [img_, x0, y0] = subimg(img,x,y,r,smooth)
% retrieve a subimage centered around point x,y of size 2r+1
% if the coordinate is close to the edge, shift the square so that it is within the image
% also returns x0 y0 as the numbers which can be added to positions within the image to get position in the larger image.
% Lastly, smooth the image if requested
x = round(x); y = round(y);

sx = size(img,2);
sy = size(img,1);
if x<=r; x=r+1; end
if y<=r; y=r+1; end
if x>(sx-r); x=sx-r; end
if y>(sy-r); y=sy-r; end
x0 = x-r-1;
y0 = y-r-1;

img_ = img(y-r:y+r,x-r:x+r);
img_ = imgaussfilt(img_,smooth);
end
