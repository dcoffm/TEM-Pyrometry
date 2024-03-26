function TotalError = RunError(this)

    % Minimize the sum of individual fit errors
    TotalError = sum( this.FitError );
    
    % Add some bias towards negative EmissB until the simplex is smaller so it settles on a local min?
    TotalError = TotalError .* (1 + this.Bbias*(200*this.Bintercept)^2);
    
    % Add error for exceeding parameter bounds
    boundErr = 1e3;
    for i = 1:numel(this.papp)
        TotalError = TotalError * (1 + boundErr*(this.papp(i) > this.SeedStruct(i).BoundUpper));
        TotalError = TotalError * (1 + boundErr*(this.papp(i) < this.SeedStruct(i).BoundLower));
    end

end