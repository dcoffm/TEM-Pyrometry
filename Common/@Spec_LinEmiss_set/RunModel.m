function this = RunModel(this)
    % Compute each T using a smaller spectral model:

    if this.Parallel  % Parallel version
        T = this.T;
        EmissA = this.EmissA;
        EmissB = this.EmissB;
        laserFits = this.laserFits;
        FitError = this.FitError;
        ModelCounts = this.ModelCounts;
        nd = numel(this.D);
        parfor i = 1:nd
            C = Spec_LinEmiss_single(this,this.D(i),this.L(i));
            C.seedAppend('T', 1200, 0, 4000);
            C.seedAppend('EmissA', this.Atarget*1.1, 0, 1e3);
            if this.doFitLaser; C.seedAppend('laserScale', this.laserScale, 0, 100*this.laserScale); end
            C.doPlot = false;
            C.Initialize();
            C.Iterate(150);

            % Store outputs
            T(i) = C.T;
            EmissA(i) = C.EmissA;
            EmissB(i) = C.EmissB;
            laserFits(i) = C.laserScale;
            FitError(i) = C.itErr(C.iteration);
            ModelCounts(:,i) = C.ModelCounts;
            delete(C);
        end
        this.T = T;
        this.EmissA = EmissA;
        this.EmissB = EmissB;
        this.laserFits = laserFits;
        this.FitError = FitError;
        this.ModelCounts = ModelCounts;
        clear('T','EmissA','EmissB','laserFits','FitError','ModelCounts')
        
    else % Serial version
        C = Spec_LinEmiss_single(this);
        C.seedAppend('T', 1200, 0, 4000);
        C.seedAppend('EmissA', this.Atarget*1.1, 0, 1e3);
        if this.doFitLaser; C.seedAppend('laserScale', this.laserScale, 0, 100*this.laserScale); end
        for i = 1:numel(this.D)
            C.D = this.D(i);
            C.L = this.L(i);
            C.doPlot = false;
            C.Initialize();
            C.Iterate(200);

            % Store outputs
            this.T(i) = C.T;
            this.EmissA(i) = C.EmissA;
            this.EmissB(i) = C.EmissB;
            this.laserFits(i) = C.laserScale;
            this.FitError(i) = C.itErr(C.iteration);
            this.ModelCounts(:,i) = C.ModelCounts;
        end
    end
        
end