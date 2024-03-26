classdef Spec_Cal_linear < Spec_Cal & Spec_LinEmiss
    
    % Works like LinEimss_set, but uses a known sample emissivity to get a Total System Efficiency
    
    methods
        this = InitializeModel(this)
        this = InitializePlot(this)
        this = RefreshPlot(this)
        this = RunModel(this)
        err  = RunError(this)
    end
end