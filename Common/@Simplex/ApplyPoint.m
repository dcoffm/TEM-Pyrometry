function this = ApplyPoint(this,params)
    % Fills the class model parameters with the ones provided in the argument according to the seed labels
    for i = 1:this.nCoeff
        this.(this.SeedStruct(i).Label) = params(i);
    end
    this.papp = params;
end