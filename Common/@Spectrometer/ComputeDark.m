function this = ComputeDark(this,I,tmin)
    
    % Finds a dark current (e-/s) and ADC offset (counts) from a selection (I) of spectra in the dataset
    % To distinguish current from offset, you need more than one integration time
    % This function assumes all selected spectra have the same EMG & ADCsens capture parameters
    
    % Note: try to avoid integration times at the extremely short end because they do not follow the intercept trend well
    %       -> tmin specifies cutoff, default 10ms

    if nargin<2; I = 1:this.nd; end % If no selection, select all
    if nargin<3; tmin = 0.011; end % Minimum exposure time considered
    
    nspec = numel(I);
    itimes = [this.D(I).itime];
    spectra = NaN([this.nx nspec]);
    
    if this.doPlot; figure; hold on; cmap = linspecer(nspec); end
    for i = 1:nspec
        S = this.D(I(i)).counts;
        %mask = (S - mean(S)) > 12*mean(abs(S - mean(S))); % remove cosmic rays
        %S(mask) = NaN;
        spectra(:,i) = S;
        if this.doPlot; plot(this.x,spectra(:,i),'Color',cmap(i,:),'Linewidth',1); title('As-Read'); end
    end
    
    [tunq,iunq] = unique(itimes,'sorted');
    
    % If there is more than one integration time, extrapolate intercept for ADC offset
    if numel(tunq) > 1
        tunq(tunq<tmin) = []; % Very short integration times do not help the trend.
        DC_rep = NaN([1 numel(tunq)]);
        if this.doPlot; figure; hold on; cmap = linspecer(2*numel(tunq)); end
        for i = 1:numel(tunq)
            mask = itimes==tunq(i);
            spectra_ = spectra(:,mask);
            a = spectra_ - mean(spectra_,2);
            mask = a > 12*mean(abs(a),2); % Remove cosmic rays
            spectra_(mask) = NaN;
            S = mean(spectra_,2,'omitnan');
            DC_rep(i) = mean(S(this.dataMask),'omitnan');
            if this.doPlot; plot(this.x,S,'Color',cmap(2*i,:),'Linewidth',1); title('As-Read'); end
        end
        p = polyfit(tunq,DC_rep,1);
        this.ADCoffset = p(2);
        d = this.D(I(iunq(i))); % Use the longest integration time for final dark current value.
        this.darkCurrent = (S - this.ADCoffset)./(tunq(i)*d.EMG*d.ADCsens);
        
        if this.doPlot; figure; hold on; plot(tunq,DC_rep,'o'); plot([0 tunq(end)],[0 tunq(end)]*p(1)+p(2)); box on; end
    else
        % If there is only one integration time, we can't distinguish current from offset.
        % However, if all the data is collected w/ the same integration time, the distinction doesn't matter.
        S = mean(spectra,2,'omitnan');
        d = this.D(I(1));
        this.darkCurrent = (S - this.ADCoffset)./(tunq*d.EMG*d.ADCsens);
    end

    % Looking at DCPS curves from different times,
    % there seems to be a fixed pattern CPS that doesn't change much (pixel leak?)
    % and a global offset CPS that does vary within a few minutes (thermal counts, TEC temperature variation?)
end
