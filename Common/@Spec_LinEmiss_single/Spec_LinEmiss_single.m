classdef Spec_LinEmiss_single < Spec_LinEmiss
    
    % Fits T, A, and if alone, B, for a single spectrum
    
    methods
        %this = InitializeModel(this)
        this = InitializePlot(this)
        this = RefreshPlot(this)
        this = RunModel(this)
        err  = RunError(this)
    end
    
end