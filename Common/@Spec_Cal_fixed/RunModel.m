function this = RunModel(this)
    
    this.TSE = this.InvertTSE(this.Iassume);
    this.TSE = this.TSE./this.EmissTrue; % Attempt to separate thermocouple's emissivity from calibration
    
    % Compute each T using a smaller spectral model:
    C = Spec_LinEmiss_single(this);
    C.seedAppend('T', 1200, 0, 4000);
    C.seedAppend('FOV', this.FOV, 0, this.FOV*1e6);
    if this.doFitLaser; C.seedAppend('laserScale', this.laserScale, 0, 100*this.laserScale); end
    C.writeEmiss = false;
    C.Emiss = this.EmissTrue;
    
    for i = 1:numel(this.D)
        C.D = this.D(i);
        C.L = this.L(i);
        C.doPlot = false;
        C.Initialize();
        C.Emiss = this.EmissTrue;
        C.Iterate(200);
        
        % Store outputs
        this.T(i) = C.T;
        this.FOVmod(i) = C.FOV/this.FOV;
        this.ModelCounts(:,i) = C.ModelCounts;
        this.FitError(i) = C.itErr(C.iteration);
    end
end