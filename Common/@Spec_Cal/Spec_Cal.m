classdef Spec_Cal < Spectrometer
    % Spectrometer calibration
    properties
        Ttrue     (1,:) double % The known temperature of the thermocouple for each spectrum
        EmissTrue (:,1) double % The assumed spectral emissivity of thermcouple at index Iassume
        Iassume   (1,1) double 
    end
    methods
        TSE  = InvertTSE(this,I) % Derive a TSE using an assumed temperature Ttrue(I)
    end
end