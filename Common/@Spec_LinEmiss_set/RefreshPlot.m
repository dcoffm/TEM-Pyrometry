function this = RefreshPlot(this)

    this.PlotHandles.model.YData = this.T;
    str = sprintf('Iteration:  %i\n',this.iteration);
    
    strLabels = pad({this.SeedStruct.Label});
    for i = 1:numel(this.papp)
        str = [str sprintf('%s %+7.4e\n',strLabels{i},this.papp(i)) ];
    end
    this.PlotHandles.text.String = str;
    drawnow;
    if this.pauseTime > 0; pause(this.pauseTime); end
end