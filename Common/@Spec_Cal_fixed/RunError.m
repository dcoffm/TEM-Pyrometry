function TotalError = RunError(this)
    
    % Minimize differences in temperatures as computed with spec/thermocouple    
    TotalError = sum(abs( this.Ttrue - this.T ));
    
    % Add a bit of error from fit quality to improve result
    TotalError = TotalError + 0.5*sum(this.FitError)/this.nx;
    
    % Add error for exceeding parameter bounds
    boundErr = 1e3;
    for i = 1:numel(this.papp)
        TotalError = TotalError * (1 + boundErr*(this.papp(i) > this.SeedStruct(i).BoundUpper));
        TotalError = TotalError * (1 + boundErr*(this.papp(i) < this.SeedStruct(i).BoundLower));
    end

end