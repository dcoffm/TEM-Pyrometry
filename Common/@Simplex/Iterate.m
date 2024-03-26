function this = Iterate(this,N)
    % Iterates the Nelder-Mead algorithm N times
    if N>0
        stopat = this.iteration + N;
    else
        stopat = this.iteration;
    end
    
    if stopat > numel(this.itErr)
        this.itErr = [this.itErr NaN([1 stopat-numel(this.itErr)])];
    end

    % Temporary variables to make this more readable
        p = this.points;
        perr = this.perror;
        a = this.NM_alpha;
        b = this.NM_beta;
        y = this.NM_gamma;
        k = this.NM_kappa;
    
    while this.iteration < stopat
        this.iteration = this.iteration + 1;

        % Do the algorithm
        if this.ScalingRefresh
            for m = 1:size(p,1)
                this.ApplyPoint(p(m,:));
                this.RunModel();
                perr(m) = this.RunError();
            end
            this.ScalingRefresh = false;
        end
        
        [~,ih] = max(perr); % Note points with highest/lowest error
        [~,il] = min(perr);
        
        cent = (sum(p,1)-p(ih,:))./size(p,2); % Centroid point (amongst all but the highest error)
        
        % Reflect the point with highest error
        pr = (1+a)*cent - a*p(ih,:);
        this.ApplyPoint(pr);
        this.RunModel();
        erref = this.RunError();

        % Determine what to do with reflected point:
        flag = 0;
        if erref <= perr(ih); flag = 1; end % Reflection is good
        if erref <  perr(il); flag = 2; end % Reflection is so good that expansion should be tried
        if erref >  perr(ih); flag = 3; end % Reflection is not good

        switch flag
        case 0
            error('The provided error function produced a NaN value.');
        case 1 % Stay with reflection
            p(ih,:) = pr;
            perr(ih) = erref;

        case 2 % Evaluate expansion possibility
            pex = b*pr + (1-b)*cent; % Expanded point
            this.ApplyPoint(pex);
            this.RunModel();
            erexp = this.RunError();
            
            if erexp < erref		% Go with expansion
                p(ih,:) = pex;
                perr(ih) = erexp;
            else					% Go with reflection
                p(ih,:) = pr;
                perr(ih) = erref;
            end

        case 3 % Evaluate for contraction or scaling
            pc = (1-y)*cent + y*p(ih,:); % Contracted point
            
            this.ApplyPoint(pc);
            this.RunModel();
            ercon = this.RunError();
            
            if ercon < perr(ih)	    % Go with contraction
                p(ih,:) = pc;
                perr(ih) = ercon;
            else				    % Resort to scaling
                this.ScalingRefresh = true;
                p = p + k*(p(il,:) - p);
            end
        end
        
        % Update best point
        this.pbest = p(il,:);
        this.itErr(this.iteration) = perr(il);
        this.points = p;
        this.perror = perr;
        
        if this.doPlot
            this.ApplyPoint(this.pbest);
            this.RunModel();
            this.RefreshPlot();
        end
    end
    if ~this.doPlot
        this.ApplyPoint(this.pbest);
        this.RunModel();
    end
end