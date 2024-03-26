function this = InitializePlot(this)

    this.PlotHandles.figure = figure; hold on
    this.PlotHandles.obsv   = plot(this.Ttrue,this.Ttrue,'k');
    this.PlotHandles.model  = plot(this.Ttrue,this.T,'r.');
    this.PlotHandles.axis   = gca;
    
    xlabel('No.')
    ylabel('Temperature (°C)')
    ylim([0 1.7*max(this.Ttrue)])
    box on
    set(gca,'FontSize',12)
    legend({'Observed','Model'},'Location','Northeast')
    this.PlotHandles.text = text(this.PlotHandles.axis,0.05,0.95,'.','Units','normalized','VerticalAlignment','top','FontName','Monospaced');
    this.RefreshPlot();
end