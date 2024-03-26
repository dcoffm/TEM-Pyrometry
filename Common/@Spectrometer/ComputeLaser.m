function this = ComputeLaser(this,I)

    % Assuming darkCurrent and ADCoffset are already set correctly,
    % attribute the remaining counts in I as laser scatter, with negligible blackbody contribution from sample
    
    if nargin==1; I = 1:this.nd; end % If no selection, select all
    
    cps = NaN([this.nx numel(I)]);
    mc = mean([this.D(I).counts],2);
    
    %figure; hold on; cmap = linspecer(numel(I));
    for i = 1:numel(I)
        d = this.D(I(i));
        mask = (d.counts - mc) > 12*mean(abs(d.counts - mc)); % remove cosmic rays
        d.counts(mask) = NaN;
        cps(:,i) = (d.counts - this.ADCoffset)./(d.itime * d.EMG * d.ADCsens) - this.darkCurrent;
        %plot(cps(:,i),'Color',cmap(i,:),'Linewidth',1); title('As-Read');
    end
    this.laserCurrent = mean(cps,2,'omitnan');
end

