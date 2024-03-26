function this = Initialize(this)
    % Expands the seed, resets iteration, calls plot setup

    this.nCoeff = numel(this.SeedStruct);
    this.perror = zeros(1,this.nCoeff+1);
    seed = [this.SeedStruct.InitialGuess];
    this.pbest = seed;

    this.points = repmat(seed,[this.nCoeff+1 1]);
    for k = 2:this.nCoeff+1
        if this.points(1,k-1) == 0
            this.points(k,k-1) = 0.5*this.SeedStruct(k-1).BoundUpper;
        else
            this.points(k,k-1) = 1.1 * this.points(k,k-1);
        end
    end

    this.iteration = 0;
    this.itErr = NaN([1 250]); % Pre-allocate some space. If you are going to be iterating more than this, preallocate more...
    this.ScalingRefresh = true;

	this.InitializeModel();

    if this.doPlot
        this.ApplyPoint(seed);
        this.RunModel();
        this.InitializePlot();
    end
end