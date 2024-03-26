classdef Spec_LinEmiss_set < Spec_LinEmiss
    
    properties
        Parallel (1,1) logical = false;
    end
    
    % Apply spectral pyrometry to a set of 2 or more spectra
    % -> assumes that the spectral emissivity slope can change with temperature, splitting it into 2 parameters    
    methods
        %this = InitializeModel(this)
        this = InitializePlot(this)
        this = RefreshPlot(this)
        this = RunModel(this)
        err  = RunError(this)
        
        function this = InitializeModel(this,D,L)
            if nargin == 1; InitializeModel@Spec_LinEmiss(this); end
            if nargin == 2; InitializeModel@Spec_LinEmiss(this,D); end
            if nargin == 3; InitializeModel@Spec_LinEmiss(this,D,L); end
            this.standalone = false;
        end
    end
    
end