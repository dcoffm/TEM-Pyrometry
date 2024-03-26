# TEM-Pyrometry
Matlab code for estimating temperature from spectral data using a first-principles model.

# How to use:
* Add the /Common directory to the matlab search using addpath()
* Calibrate:
  * Collect spectral data from a sample with known temperature and emissivity
  * Initialize a new spectrometer model and populate known fields like wavelength
  * Fit unknown parameters using Nelder-Mead algorithm
  * Save the model object (espcially the TSE curve) for future use
* Apply to new data:
  * Initialize a new spectrometer object with calibration model
  * Load new spectal data
  * Calculate dark current and other relevant session information
  * Fit temperatures and emissivities

For examples of the workflow, check the /Data folders


# Classes
* Spectrometer
  * Contains fields and methods for modeling the sample-spectrometer system, from Planck to ADC (analog-digital conversion)
* SpectrumCapture
  * Represents a single spectrum aquired during an experiment, with key information like counts and integration time
* Simplex
  * Contains methods for iteratively calling RunModel() and RunError() to optimize the variables listed in the .seed structure

Several derived classes from Spectrometer contain variations on the model for specific applications, such as calibration and fitting a set using a linear emissivity model.

# Key Methods
* Spectrometer.SpectrometerModel()
  * Produces a count spectrum based on current parameters
* Spectrometer.ComputeDark()
  * Attempts to fit the ADC offset and dark current given a series of dark spectra at different integration times
* Spectrometer.ComputeLaser()
  * Attempts to fit the laser current spectrum, assuming the sample temperature is negligible and other offsets have been accounted for
* Spectrometer.Visualize()
  * Plots the observed and modeled count spectra for visual comparison. Use this to qualitatively assess the quality of fit and make adjustments to the procedure if needed
* Simplex.Initialize()
  * Prepares to iterate the NM algorithm
* Simplex.Iterate()
  * Iterates the NM algorithm the specified number of times
* InitializePlot() and RefreshPlot()
  * Tells derived classes what to display during simplex iteration
 
# Fields
See class declarations and paper for more details.
