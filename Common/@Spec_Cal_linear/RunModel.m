function this = RunModel(this)

    this.TSE = this.InvertTSE(this.Iassume);
    this.TSE = this.TSE./this.EmissTrue; % Attempt to separate thermocouple's emissivity from calibration
    
    % Compute each T using a smaller spectral model:
    C = Spec_LinEmiss_single(this);
    C.seedAppend('T', 1200, 0, 4000);
    C.seedAppend('EmissA', 1, 0, 1e3);
    if this.doFitLaser
        C.seedAppend('laserScale', this.laserScale, 0, 100*this.laserScale);
    end
    
    for i = 1:numel(this.D)        
        C.D = this.D(i);
        C.L = this.L(i);
        C.doPlot = false;
        C.Initialize();
        C.Iterate(150);

        % Store outputs
        this.T(i) = C.T;
        this.EmissA(i) = C.EmissA;
        this.EmissB(i) = C.EmissB;
        this.laserFits(i) = C.laserScale;
        this.FitError(i) = C.itErr(C.iteration);
        this.ModelCounts(:,i) = C.ModelCounts;
    end
end