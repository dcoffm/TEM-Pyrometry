% Do any one-time routines necessary to set up the model for application
function this = InitializeModel(this)
    
    % Outside source must set:
    % x, D, L
    % Ttrue, EmissTrue, Iassume

    % Preallocate spectrometer variables
    this.nx = numel(this.x); nx = this.nx;
    this.nd = numel(this.D); nd = this.nd;
    this.T = NaN([1 nd]);
    this.Emiss = repmat(this.EmissTrue,[1 nd]); % Make sure input dimension is correct
    this.ModelCounts = NaN([nx nd]);
    this.FitError = NaN([1 nd]);
    
    this.EmissA = ones([1 nd]); % Not used, but needed for Visualize() function
    this.EmissB = ones([1 nd]);
    this.laserFits = zeros([1 nd]);
    
    % Specific to fixed cal:
    this.FOVmod = NaN([1 nd]);
end