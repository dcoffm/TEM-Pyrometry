function TotalError = RunError(this)
    
    % Minimize misfit of model to observed counts, excluding anything masked out by dataMask
    differ = this.D.counts - this.ModelCounts;
    TotalError = sum(abs( differ(this.dataMask) ),'omitnan');
    
    % Also add some error for getting too crazy with EmissA / FOV
    TotalError = TotalError *(1 + 0.2*abs( (log(this.EmissA) - log(this.Atarget)) )^2 );
    
    % Add error for exceeding parameter bounds
    boundErr = 1e3;
    for i = 1:numel(this.papp)
        TotalError = TotalError * (1 + boundErr*(this.papp(i) > this.SeedStruct(i).BoundUpper));
        TotalError = TotalError * (1 + boundErr*(this.papp(i) < this.SeedStruct(i).BoundLower));
    end

end