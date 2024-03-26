classdef Spec_LinEmiss < Spectrometer
    
    properties
        x0         (1,1) double  = 800 % Central wavelength of spectrometer, from which specral slope is applied
        EmissA     (1,:) double  = 1 % Emissivity magnitude
        EmissB     (1,:) double  = 0 % Emissivity spectral slope
        laserFits  (1,:) double  = 0 % Scaling of laser current curve
        Bslope     (1,1) double  = 0 % temperature dependence of EmissB
        Bintercept (1,1) double  = 0 % temperature dependence of EmissB
        Atarget    (1,1) double  = 1 % Approximate emissivity magnitude (EmissA) to aim for, with some allowance for changing FOV
        Bbias      (1,1) double  = 1 % How strongly to prefer EmissB be small... Added in response to high B/low A mirror
        
        % Options altering fitting behavior to different situations
        standalone (1,1) logical = true; % Whether this is being run for a single spectrum or as part of a set (affects RunModel)
        writeEmiss (1,1) logical = true; % If set to false, will skip the ModelEmiss step (for cal_fixed)
        doFitLaser (1,1) logical = true; % Whether we will add laserScale to our parameter list (set to 0 if laser current is not known)
    end
    
    methods
        function this = InitializeModel(this,D,L)
            if nargin == 1; InitializeModel@Spectrometer(this); end
            if nargin == 2; InitializeModel@Spectrometer(this,D); end
            if nargin == 3; InitializeModel@Spectrometer(this,D,L); end
            
            this.x0 = median(this.x);
            this.EmissA = ones([1 this.nd]);
            this.EmissB = ones([1 this.nd]);
            this.laserFits = zeros([1 this.nd]);
        end
        
        function this = CopyParent(this,parent)
            CopyParent@Spectrometer(this,parent);
            
            this.Atarget = parent.Atarget;
            this.Bslope  = parent.Bslope;
            this.Bintercept = parent.Bintercept;
            this.x0 = parent.x0;
            this.standalone = false; % It seems like the only time we use this copy function is in the context of optimizing a set
        end
        
        function this = ModelEmiss(this)
            for i = 1:this.nd
                this.EmissB(i) = this.Bintercept + this.Bslope * this.T(i);
                this.Emiss(:,i) = this.EmissA(i) * (1 + this.EmissB(i)*(this.x - this.x0));
            end    
            if this.standalone % Ensure Atarget doesn't do anything in error function
                this.Atarget = this.EmissA;
            end
        end
        
    end
    
end