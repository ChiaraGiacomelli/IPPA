# IPPA
**Interactive Polysome Profile Analyser**
**CC-BY**

This Shiny app has been created to read in csv files from BioComp Gradient Fractionators and calculate the area under the curve (AUC) of polysome profiles to do monosome to polysome (or subpolysome to polysome) ratios.

The basis of this shiny app is a function written by Joseph Waldron, currently Associate Scientist in the lab of Martin Bushell at CRUK Scotland Institute.

**Usage**
1) Upload your csv file from the biocomp machine
   Optional: first upload a blank profile and use it to set the baseline absorbance, which will be subtracted from the absorbance of samples during AUC calculation
2) In the fields Start of 80s and End of 80s, manually set the values or move the arrows up and down to define the monosome peak
3) If needed, define the Max Volume, the point at which the data is not considered any longer for the AUC calculation. This can be needed if the end of the curve is very noisy.
4) Save the plot - this will be save in the output directory which you have specified in the first field.
   Plot name is the same name as the csv file, followed by _vol_date or _FN_date, depending whether the x axis it toggle between volume or fraction number, respectively.
5) Calculate AUC: this will calculate the AUC minus baseline for the 80s and the polysomes.
   The values, as well as the numeric boundaries used for the calculations, and the monosome to polysome ratio, are all displayed in a table under the plot.

Repeat the uploading, plotting, and calculation for all the gradients you want to analyse
Then export the csv file for further processing
   
