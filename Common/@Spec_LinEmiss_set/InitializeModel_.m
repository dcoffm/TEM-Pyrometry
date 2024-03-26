% Do any one-time routines necessary to set up the model for application
function this = InitializeModel(this)
    
    % Outside source must set:
    % x, D, L
    
    %{
    % Preallocate spectrometer variables
    this.nx = numel(this.x); nx = this.nx;
    this.nd = numel(this.D); nd = this.nd;
    this.T = NaN([1 nd]);
    this.Emiss = ones([nx nd]);
    this.ModelCounts = NaN([nx nd]);
    this.FitError = NaN([1 nd]);

    % Preallocate linear model variables
    this.x0 = median(this.x);
    this.EmissA = ones([1 nd]);
    this.EmissB = ones([1 nd]);
    this.laserFits = zeros([1 nd]);
    this.standalone = false;
    %}
end