# IPPA
**Interactive Polysome Profile Analyser**

This Shiny app has been created to read in csv files from BioComp Gradient Fractionators and calculate the area under the curve (AUC) of polysome profiles to do monosome to polysome (or subpolysome to polysome) ratios.
Developed and currently running on R version 4.3.3 (2024-02-29 ucrt) -- "Angel Food Cake"

The function to calculate the AUC was originally written by Joseph Waldron, currently Associate Scientist in the lab of Martin Bushell at CRUK Scotland Institute.

**Usage**
1) Upload your csv file from the BioComp machine.
   
   Optional: first upload a blank profile and use it to set the baseline absorbance, which will be subtracted from the absorbance of samples during AUC calculation.
   A test profile from a mouse liver (courtesy of the lab of Hanna Hörnberg at the Max Delbrück Center for Molecular Medicine) is available here to test.
   
   The liver_test.png file shows how the app should look like upon loading the csv file.
   
2) If you would like to save the plots, paste the path in the Plots Output Directory field (does not matter if the file path has \ or / , it will automatically be corrected)
   
3) In the fields Start of 80s and End of 80s, manually set the values or move the arrows up and down to define the monosome peak.
   These values are based on the volume of the gradients, even when the plot is displaying the fraction numbers
   
4) If needed, define the Max Volume, the point at which the data is not considered any longer for the AUC calculation. This can be useful if the end of the curve is very noisy.
   
5) Save the plot as png files
   
   The plot name is automatically the same name as the csv file, followed by _vol_date or _FN_date, depending whether the x axis it toggle between volume or fraction number, respectively. This toggling affects only the data display and not the AUC calculation.
   
6) Calculate AUC: this will calculate the AUC minus baseline for the 80s and the polysomes.
   The values, as well as the numeric boundaries used for the calculations, and the monosome to polysome ratio, are all displayed in a table under the plot.

7) Repeat the uploading, plotting, and calculation for all the gradients you want to analyse, then export the csv file for further processing
   
**CC-BY**
Chiara Giacomelli

20250616

Currently PostDoc in the Proteome Dynamics lab of Matthias Selbach at the Max Delbrück Center for Molecular Medicine
