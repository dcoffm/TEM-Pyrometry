% General class for applying the Nelder-Mead simplex algorithm to optimize model parameters

classdef Simplex < handle_light & matlab.mixin.Copyable
    
    properties
        % Nelder-Mead parameters
        NM_alpha double = 0.98 % Reflection factor
        NM_beta  double = 1.97 % Expansion factor
        NM_gamma double = 0.48 % Contraction factor
        NM_kappa double = -1   % Scaling factor
        
        % Vertices & associated error
        nCoeff (1,1) uint8  % Number of parameters
        points (:,:) double % Test points in parameter space
        perror (1,:) double % Error associated with points
        pbest  (1,:) double % The parameter set with best fit so far
        papp   (1,:) double % Currently applied parameter set (for bounds checking)
        
        % Iteration variables
        iteration (1,1) uint32 = 0 % Number of times the NM algorithm has been run
        itErr (1,:) double % Best error associated with each iteration
        ScalingRefresh (1,1) logical = true
        
        % Plotting
        doPlot logical = true
        pauseTime double = 0
        PlotHandles
        
        % Model I/O
        SeedStruct (1,:) % User input with parameter labels, guesses, and bounds
        Input
        OutputObserved
        OutputModel
    end
    
    methods
        function this = Simplex_core(); end        
        this = Initialize(this)        
        this = Iterate(this,N)
        this = ApplyPoint(this,params)
        
        function this = seedAppend(this,label,guess,boundlow,boundup)
            
            if nargin < 4; boundlow=NaN; end
            if nargin < 5; boundup =NaN; end
            
            if isempty(this.SeedStruct)
                this.SeedStruct = struct('Label',label,'InitialGuess',guess,'BoundLower',boundlow,'BoundUpper',boundup);
            else
                this.SeedStruct(end+1) = struct('Label',label,'InitialGuess',guess,'BoundLower',boundlow,'BoundUpper',boundup);
            end
        end
        function this = seedClear(this)
            this.SeedStruct = [];
        end
        
    end
    
    % To be defined by the child class:
    methods (Abstract)
       InitializeModel % Model-specific steps that need to be carried out before running
       InitializePlot  % Setup the figure for showing iterative fitting
       RunModel        % Generate output from input + parameters
       RunError        % Compute an error value by comparing model vs observed output
       RefreshPlot     % Updating the figure
    end
    
end