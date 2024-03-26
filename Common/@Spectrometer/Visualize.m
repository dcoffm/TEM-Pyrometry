function Visualize(this,I)
    N = numel(I);
    % Make many individual plots, easy to close from stack
    for i = 1:N
        F=figure; hold on;
        F.Position = [1924,554,847,414];
        plot(this.x,this.D(I(i)).counts,'k')
        plot(this.x,this.ModelCounts(:,I(i)),'r')
        d = this.D(I(i));
        background = this.ADCoffset + d.itime * d.EMG * d.ADCsens * (this.darkCurrent + this.laserFits(I(i)).*this.laserCurrent.*this.L(I(i))); 
        plot(this.x,background,'Color',[0.7 0.7 0.7])
        legend({'Observed','Model','Background'},'Location','northeastoutside')
        str = sprintf('i = %u\nT = %0.1f °C\nE0 =  %e\nE1 = %+e nm^-^1\nLaserScale = %0.1f',I(i),this.T(I(i)),this.EmissA(I(i)),this.EmissB(I(i)),this.laserFits(I(i)));
        text(gca,1.04,0.77,str,'Units','normalized','VerticalAlignment','top','EdgeColor',[0 0 0],'BackgroundColor',[1 1 1],'FontName','Monospaced');
        box on
        xlabel('Wavelength(nm)')
        ylabel('Counts')
        set(gca,'FontSize',12)
        xlim([this.x(1) this.x(end)])
        y0 = this.ADCoffset;
        y1 = max(this.D(I(i)).counts);
        ylim([y0-0.1*(y1-y0) y1+0.1*(y1-y0)])
        title(this.DatasetLabel)
    end
    drawnow
    
end