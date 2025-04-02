WORK IN PROGRESS.....STAY TUNED FOR THE FIRST BETA RELEASE PROBABLY IN ERALY APRIL 2035


# SeestarPhotometricWatchdog
A collection of simple scripts to perform on-the-fly photometry with the ZWO Seestar series telescopes in order to spot variabilities in real-time, e.g. for catching the erruption of T CrB.

For simplicity, this is intended to be run on a Raspberry Pi connected to the same network that the Seestar telescope is using, so that the code can access images generated by the Seestar via the SMB network share //Seestar/. 

This is work in progress. The intention was to get something up and running fast before T CrB errupts. The main usecase is to let the rtelescope record images as long as possible and even unattended. The code can be customized to then wake up the user or send messages out in case it detects a change in brightness that warrants human inspection.


Installing required software:
=============================

1) Siril

Siril (and importantly its command line variant siril_cli) can be installed from the Raspberry Pi OS repository :

```sudo apt-get install siril```

NOTE: the script are written for the rather old version of Siril that is included in the 
Raspberry Pi OS "Bookworm" repository (at the time of writing). For newer versions, the code 
in the scr folder might need adjustments. 

2) ASTAP

For  ASTAP and its command line interface astap-cli, wee need a newer version than the one provided by the "Bookworm" repository. I suggest to follow install instruction on

At the time of writing:

```
wget https://altushost-swe.dl.sourceforge.net/project/astap-program/linux_installer/astap_armhf.deb -O astap_armhf.deb
wget https://master.dl.sourceforge.net/project/astap-program/star_databases/v50_star_database.deb -O v50_star_database.deb
wget https://master.dl.sourceforge.net/project/astap-program/linux_installer/astap_command-line_version_Linux_aarch64.zip

sudo dpkg -i astap_armhf.deb v50_star_database.deb
unzip astap_command-line_version_Linux_aarch64.zip
cp astap_cli /opt/astap/
```

3) Stilts

For cross matching tables and to generate diagnostic plots, we use stilts, the command-line sister-tool of "Topcat".
This software uses JAVA and will install quite a few dependent packages, so installation might take some time.

```sudo apt-get install stilts``` 

4) SMB client for Python

This is used to copy image files from the Seestar as they are acquired.

```sudo apt-get install python3-smbc```

5) Astropy Utils

```sudo apt-get install astropy-utils```


6) Optional : tools for playing example sound file in OGG format

```sudo apt-get install vorbis-tools```

 


Checking the Seestar configuration
==================================
TODO ...

* Seestar will make new images accessible to other computers on the same network in folders named TARGET_sub where TARGET is either the name of  the catalog object used to point the Seestar, or the custom object that you defined yourself (by specifying coordinates). The default settings in the script assume you are pointing at "T CrB".
* You need to configure Seestar so it retains all "good" sub-frames when stacking.
* Depending on the weather forecast, do not forget to turn on the anti-dew heater if that might help to keep the optics clear
* You can use the Seestar App's "plan feature" to make Seestar observe for a certain time window, and then close it's arm again (e.g. begin the observation when T CrB becomes vissible from your observation site, and end the observation run when the sun sets or the star gets to low over the horizon

Customizing the scripts and cofiguration:
=========================================
As a watchdog for *T CrB*, used on a Raspberry Pi, the script shoudl run out-of-the-box without any need for changes. However there can be a few reasons why you might want to customize the scripts and configuration files #


* You have a newer version of Siril which doesn't seem to work with the script as-is: ....
* You want o set different alarm thresholds or different conditions for checking the photometry of the comparison stars: ---
* You want to interface to some home-automation system or other ways to make you wake up at night in the event of a nova from *T CrB*: ....
* Uploading the dataproducts to your webspace is more complicated than just copying the files to some folder: ...
* You want to use a different software for stacking/platesolving/photometry: ...
* You want to use the other RGB filter cannels as well, not just the green channel: ....  

  

Using the script:
==================
The pipeline runs in a continuous loop, which is started by a call to the (surprise!) loop.sh script followed by six comamnd line arguments like this:

```./loop.sh [TARGET] [SUBS_TO_STACK] [MIN_COMPS] [WAIT_FOR_FRAMES] [WEBDIR] [ARCHIVE_DIR] ```

Where :
* ``TARGET`` is the name of the target object used by Seestar (case-sensitive). **IMPORTANT**: If the name includes spaces, use double quotes as in ``"T CrB"``
* ``SUBS_TO_STACK`` is the number of frames to stack for each measurement. Using more frames decreases the chance of a false alarm as you will get a more accurate measurement most of the time, but it will also make the script take longer to react to change.
* ``MIN_COMPS`` is the minimum number of compüarison stars to be detected and measured with their correct magnitudes in order for a stacked image to be considered usable for photometry. For example, the example configruartion file for *T CrB* uses a total of four comparison stars, but you might want to allow one of them to be not detected (e.g. if the star drifts away from the center of the frame too much).
*  ``WAIT_FOR_FRAMES`` is the time in seconds that the script should sleep in between attempts to get new images. You probably don't want to constantly bombard the Seestar with requests over the network to check for new files.
*  ``WEBDIR`` is a directory accessible by the script where it can put the  current checkplot and current photometry report file. This could be a directory in the filesystem of the computer that is executing the script (if that computer is hosting a webserver itself) or perhaps a remote directory shared via *SMB* to access a webspace on a different host in your network. Newly generated files will overwrite files generated earlier.
*  ``ARCHIVE_DIR`` a directory to put the check plots and photometry report files, with their names appened with a timestamp so that newly generated files will not overwrite previous files.   

Note: The last two arguments ``WEBDIR`` and ``ARCHIVE_DIR`` are exclusively used as arguments to the ``publish.sh`` script and their functionality as described above is just that of the version of ``publish.sh`` contained in this repository. If you decide to customize ``publish.sh`` to your individual needs (as you probably should), you are free to change the semantics of these two parameters within the script. 

An example command line could be:

```./loop.sh "T CrB" 4 3 60 /var/www/htdocs/T_CrB_watch/ /home/pi/T_CrB_archive/ ```

which will 
* look for new images in the folder "T CrB_subs" on the Seestar's network share ``"//seestar/EMMC Images/MyWorks/"``
* will stack 4 new images and then try to evaluate the srtacked image (green filter only)
* will wait 60 seconds if it cannot find at least 4 new images before retrying.
* will put files for a webspace into ``/var/www/htdocs/T_CrB_watch/``
* and will archive dataproducts to ``/home/pi/T_CrB_archive/ ``

Note: If you start the script in a shell (perhaps via ssh) and the close the shell, the loop script will be killed and the pipeline will stop! If this is not what you want, you might want to use e.g.

``` nohup ./loop [command line arguments]  &```

instead which will start the loop script in the background and will keep it alive even if the shell that it was started in is terminated. To stop it again you would then have to use the ``kill`` command. An alternative to this is using tools like ``screen`` or ``tmux`` which allow to atatch to and detach from sessions without killing them. 





Dataproducts
=============

...


FAQ
===

## Can I use this under Windows?
Not yet....

## How do I access the Seestar images remotely while it is observing?
....


## How can I check that the script is actually working ok?
....temporarily change the thresholds in the photometry reference file to trigger an alarm....

## I only want to be notified when the T CrB Nova is already bright, to be on the safe side. Should I set the alarm threshold to something like mag 6 or 5 ?
No, this is not advisable: *T CrB* is a really bright star and in the default configuration of the Seestar (10s exposure time for frames, gain setting at 80), there is not that much headroom left before the star will saturate the sensor. This means there is a limit to how bright the Seestar can measure the star with the software used in this solution. I would recommend to set the threshold to no smaller value than 8 mag.


## The script tells me that T CrB is now brithening, but when I look at the live view in the Seestar App, *T CrB* looks as bright as always. Should I go to bed again?
Careful! What you are looking at in the Seestar App is probably the *live-stacking view*, in other words the averaged images of the current session which might actually have started several hours ago! A recent change in brightness of *T CrB* will not be immediately visible in this view.
To check the validity of the alarm, you will want to check the *latest single frames* in the "T CrB_sub" folder on the network driver that the Seestar is exporting. They are stored there both as FITS and JPEG files.

