function this = InitializePlot(this)
       
    this.PlotHandles.figure = figure; hold on
    this.PlotHandles.model  = plot(1:this.nd,this.T,'r.');
    this.PlotHandles.axis   = gca;
    
    xlabel('No.')
    ylabel('Temperature (°C)')
    ylim([0 1.7*max(this.T)])
    xlim([0 this.nd+1])
    box on
    set(gca,'FontSize',12)
    legend({'Model'},'Location','Northeast')
    this.PlotHandles.text = text(this.PlotHandles.axis,0.05,0.95,'.','Units','normalized','VerticalAlignment','top','FontName','Monospaced');
    this.RefreshPlot();
end