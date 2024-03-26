function this = InitializePlot(this)

    this.PlotHandles.figure = figure; hold on
    this.PlotHandles.obsv   = plot(this.x,this.D.counts,'k');
    this.PlotHandles.model  = plot(this.x,this.ModelCounts,'r');
    this.PlotHandles.axis   = gca;
    
    xlabel('Wavelength (nm)')
    ylabel('Counts')
    ylim([this.ADCoffset-10 1.2*max(this.D.counts)])
    box on
    set(gca,'FontSize',12)
    legend({'Observed','Model'},'Location','Northeast')
    this.PlotHandles.text = text(this.PlotHandles.axis,0.05,0.95,'.','Units','normalized','VerticalAlignment','top');
    this.RefreshPlot();
end