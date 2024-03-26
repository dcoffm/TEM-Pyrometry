classdef SpectrumCapture < matlab.mixin.Copyable
    
    % Structure representing a single spectrum capture (counts) and the state of the spectrometer at time of capture
    
    properties
        counts  (:,1) double       % The measured counts for each pixel [count]
        countss (1,1) double = NaN % The summed counts, useful for quickly plotting data before further analysis
        itime   (1,1) double = 1   % The exposure duration [s]
        Navg    (1,1) double = 1   % Number of captures averaged together to produce recorded count
        t       (1,1) double = NaN % Time of capture [s]
        
        % Spectrometer-specific information
        TEC     (1,1) double = -15 % Thermoelectric cooling temperature [°C]
        ADCsens (1,1) double = 1   % The electron to ADU ratio [e/count] or the index to a preset list of such
        EMG     (1,1) double = 1   % Electron-multiplying gain [1] or the index to such
        PAG     (1,1) double = 1   % Pre-amp gain [1] or index
        HSS     (1,1) double = 3   % Horizontal shift speed or index
        VSS     (1,1) double = 2   % Vertcial shift speed or index
        AmpMode (1,1) double = 0   % Whether the spectrometer is in Pre-Amp mode or EMG mode, if applicable
        
        fname   = '' % Filename this was loaded from, if individually named
        x (:,1) double = [] % wavelength of each pixel; should not change within a given experiment [nm]
    end
    methods
        function this = SpectrumCapture(); end
        function this = SumCounts(this)
            this.countss = sum(this.counts,'omitnan');
        end
    end
end