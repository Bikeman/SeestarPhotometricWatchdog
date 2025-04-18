# Advanced User Documentation
=============================

This page contains documentation that might be of interest for users who want to change the provided scripts
according to tehir needs, either to improve them, them adapt to their own equipment and IT environment or who 
want to use the software for targets other than *T CrB*.

## Photometric reference configuration file 

The file  `phot_ref.csv` is a comma-separated-value text file table containing all photometry 
configuration data for the target star and comparison stars in the same field. 

Here is an example:

```
type,label,RA,DEC,REFMAG,REFMAG_MIN,REFMAG_MAX
V,T CrB,239.87566667,25.92016667,10.0,9.5,10.5
C,98,239.61842346,25.94191742,9.809,9.5,10.0
C,112,239.71340942,25.83472252,11.166,10.9,11.4
C,106,239.8600769,26.14641762,10.554,10.3,10.8
C,124,239.89250183,25.7381382,12.366,12.0,12.7
```

The first line defines column names for the table columns that are separated by comma. 

The first `type` column's vale  must be either a "V" or "C", to mark the varibale (target star) or several 
comparison stars, respectively. It is strongly recommended to define more than two comparison stars to allow the sofware to better assess the quality of the frames.

The `label` column contains a string with the label of the star (target star or camparison star) to be used 
for the disgnostic plot (see below). Traditionally, the label for comparison stars (as used in AAVSO finder charts) 
is the V magnitude multiplied by 10 and rounded to an integer value. 

The next two cloumns, `RA` and `DEC` hold the coordinates of the respective star in J2000 equatorial 
coordinates, in degreees and decimal notation. Do not use hours for the RA value and do not use the sexagesimal notation here!

The `REFMAG` value is the reference magnitude in V band for the star, and is actually only used for the 
comparison stars. Usually you will want to take this value from the photometric table of aN AAVSO 
finder chart. 

The meaning of the next two columns `REFMAG_MIN` and `REFMAG_MAX` differs for the target star and the comparison stars:
For the target star, this defines the thresholds for the measured magnitude value that will trigger the script 
to consider the target star either in `BRIGHT` or `FAINT` state. 
For the comparison stars, the magnitude range is used for the qulaity check of frames: 
If the measured magnitude values for too many comparison stars falls outside their respective min-max ranges, 
the entire frame is rejected and no alarm will be triggered irrespective of the measured magnitude value of the target star. 
The minimum number of "good" comparison star measurements is defined on the command line that is used to start the `loop.sh` script.



## Data Products 

Everytime the script finds enough new frames to generate a new stacked image for photometric evaluation, 
it will create a few files in the `work/analysis` subfolder based on the outcome of the analysis, both for human inspection and in a machine-readable form:

### Checkplot 
After each analyis of a stacked frame, a checkplot is generated, to allow a quick-look check of the 
pipeline processing status. The plot is meant to loosly resemble an AAVSO finder chart to be intuitive.

The X and Y axes are the RA and DEC coordinate system axes. The target star and the comparison stars are
annnotated with their respectivce labels defined in the `photo_ref.csv` file (see above), other stars in the field are 
just marked bith dots for illustrative reasons. If the photometric analysis succeeeds in measuring their magnitude vaklues, the target star and the comparison stars are highlighted with solid circles, their radii indicative of their magnituide values. The measured magnitude values , multiplied by 10 and rounded to an integer value, are printed below their respective values. For the comparison stars, this means that for "good images", the 
star labels and the magnitude values printed below them should closely match (the allowed tolerances are definied in the `photo_ref.csv` configuration file, see above). So when performing a session watching `T CrB`, you will usually see values like `100`, `99` , `98` or `97` below the label `T CrB` whcih will indicate that the star's V magnitude is between 10.0 and 9.7 (rounded), the usual values in quiescence. 

At the top of the diagram you will find the most important information about the current state of the pipeline:

A **time stamp** (in UTC time) for the most recently received stacked frame. If there is a 
significant gap between the current wallclock time (in UTC !!) and this timestamp, this means that the pipleine has not received any useable frames for a while. This could have the following reasons:

a) The Seestar has not recorded new images for a while because of clouds or haze moving through the field.

b) The Seestar is powered down or has closed itself, either because it is low on battery, it was actively shut down or because the programmed observation sequence has ended.

c) The network connection to the Seestar has been broken. Make sure the Seestar is positioned with the range of the WiFi network that is used. 
 

The heading of the plot also shows the current **alarm status** in round brackets. It will have one of the following values:

a) Status **OK** : The brighness of the target star (*T CrB* by default) is measured in the nominal range (as defined in the `photo_ref.csv` configuration file). Nothing usnusal is detected. 

b) Status **PHOTOM_UNCERT** : The measured magnitudes of the comp stars are unusual enough not to trust the photometric analysis. No alarm should be triggered oin this case.

c) Status **UNKN** : This state is a bit tricky, it means that the pipeline failed to measure the target star's brightness even though enough comparison stars were detected and looked ok. This could mean that the target star's brightness has either fallen below the limiting magnitude for the pipleine to detect it at all, or has risen so much that the saturated image of the star is exceeding the pipleines capability to make a meaningful measurement. To be on the safe side, it's best to trigger an alarm on this case for human inspection to clarify the situation, but you can edit the script `publish.sh` to ignore this case if you don't want an alarm in this case.

d) Status **FAINT**: The target star's brighness has fallen below the configured threshold

e) Status **BRIGHT** : The target star's brighness is now exceeding the configured threshold. For *T CrB*, this is what we are looking for, so in this case an alarm is triggered by the pipeline.


## Analysis status file
....



### Analysis status file for the current alarm status
....
 





