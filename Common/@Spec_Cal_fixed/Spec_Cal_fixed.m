classdef Spec_Cal_fixed < Simplex_SpecCal & Simplex_LinEmiss
    properties
        FOVmod (1,:) double
    end
    
    methods
        this = InitializeModel(this)
        this = InitializePlot(this)
        this = RefreshPlot(this)
        this = RunModel(this)
        err  = RunError(this)
    end
end