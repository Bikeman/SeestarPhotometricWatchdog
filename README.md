

# SeestarPhotometricWatchdog
A collection of simple scripts to perform on-the-fly photometry with the ZWO Seestar series telescopes in order to spot variabilities in real-time, e.g. for catching the erruption of T CrB.

For simplicity, this is intended to be run on a Raspberry Pi (model 3,4,or 5) running the 64bit version of Raspberry Pi OS "Bookworm", connected to the same network that the Seestar telescope is using, so that the code can access images generated by the Seestar via the SMB network share //Seestar/. 

This is work in progress. The intention was to get something up and running fast before T CrB erupts. 
The main usecase is to let the telescope record images as long as possible and even unattended. 
The code can be customized to then wake up the user or send messages out in case it detects a change in 
brightness that warrants human inspection.

Disclaimer: This sofware is intended to be used in connection with the ZWO Seestar S50 product, but was developed indenpendently. Teh author of thsi software is not related to ZWO. 


# Installing required software:

1) Siril

Siril (and importantly its command line variant siril-cli) can be installed from the Raspberry Pi OS 
repository :

```sudo apt-get install siril```

NOTE: the scripts are written for the rather old version of Siril that is included in the 
Raspberry Pi OS "Bookworm" repository (versionb 1.0.6 at the time of writing). For newer versions, the code 
in the `scr` folder might need adjustments. 

2) ASTAP

For  ASTAP and its command line interface `astap_cli`, we need a newer version than the one provided by 
the "Bookworm" repository. I suggest to follow install instruction on `https://www.hnsky.org/astap.htm`

At the time of writing (for the Raspberry Pi , 64 bit OS):

```
wget https://www.hnsky.org/astap_aarch64.deb -O astap_aarch64.deb
wget https://master.dl.sourceforge.net/project/astap-program/star_databases/v50_star_database.deb -O v50_star_database.deb
wget https://master.dl.sourceforge.net/project/astap-program/linux_installer/astap_command-line_version_Linux_aarch64.zip

sudo dpkg -i astap_aarch64.deb v50_star_database.deb
unzip astap_command-line_version_Linux_aarch64.zip
cp astap_cli /opt/astap/
```

3) Stilts

For cross matching tables and to generate diagnostic plots, we use stilts, the command-line sister-tool 
of "Topcat".
This software uses JAVA and will install quite a few dependent packages, so installation might take some 
time.

```sudo apt-get install stilts```

4) SMB client for Python

This is used to copy image files from the Seestar as soon as they are acquired.

```sudo apt-get install python3-smbc```

5) Astropy Utils

```sudo apt-get install astropy-utils```


6) Tools for playing example sound file in OGG format

```sudo apt-get install vorbis-tools```

 
7) Optional : webserver to allow remote access (in your LAN) to the most recently generated data products 

```sudo apt-get install lighttpd```

This will install a tiny web server on the Raspberry Pi. This is probably an option for more advanvced users.


# Checking the Seestar configuration

Seestar will make new images accessible to other computers on the same network in folders named TARGET_sub where TARGET is either the name of  the catalog object used to point the Seestar, or the custom object that you defined yourself (by specifying coordinates). The default settings in the script assume you are pointing at "T CrB".

There are a few settings that you have to check in the configuration settings of your Seestar:

* You need to configure Seestar so it retains all "good" sub-frames when stacking.
* Depending on the weather forecast, do not forget to turn on the anti-dew heater if that might help to keep the optics clear
* You can use the Seestar App's "plan feature" to make Seestar observe for a certain time window, and then close it's arm again 
(e.g. begin the observation when T CrB becomes vissible from your observation site, and end the 
observation run when the sun sets or the star gets too low over the horizon.


# Customizing the scripts and configuration:

As a watchdog for *T CrB*, used on a Raspberry Pi, the script shouls run out-of-the-box without any need 
for changes. However there can be a few reasons why you might want to customize the scripts and 
configuration files 


* You have a newer version of Siril which doesn't seem to work with the script as-is: see the alternative script in the `scr` folder.
* You want to set different alarm thresholds or different conditions for checking the photometry of the comparison stars
* You want to interface to some home-automation system or other ways to make you wake up at night in the event of a nova from *T CrB*
* Uploading the dataproducts to your webspace is more complicated than just copying the files to some folder
* You want to use a different software for stacking/platesolving/photometry
* You want to use the other RGB filter cannels as well, not just the green channel

In all of these cases, you will want to read the Adv_Documentation.md to get a deeper understanding of the configuration and inner workings of this pipeline. 


# Using the script:

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

```./loop.sh "T CrB" 4 3 60 /var/www/html/T_CrB_watch/ /home/pi/T_CrB_archive/ ```

which will 
* look for new images in the folder "T CrB_subs" on the Seestar's network share ``"//seestar/EMMC Images/MyWorks/"``
* will stack 4 new images and then try to evaluate the srtacked image (green filter only)
* will wait 60 seconds if it cannot find at least 4 new images before retrying.
* will put files for a webspace into ``/var/www/html/T_CrB_watch/``
* and will archive dataproducts to ``/home/pi/T_CrB_archive/ ``

Note: If you start the script in a shell (perhaps via ssh) and the close the shell, the loop script will be killed and the pipeline will stop! If this is not what you want, you might want to use e.g.

``` nohup ./loop [command line arguments]  &```

instead which will start the loop script in the background and will keep it alive even if the shell that it was started in is terminated. To stop it again you would then have to use the ``kill`` command. An alternative to this is using tools like ``screen`` or ``tmux`` which allow to atatch to and detach from sessions without killing them. 



# Maintenance: Periodic tasks you need to perform to keep the pipeline happy

## Educate people (and animals) within hearing distance of the alarm that this is nothing no panic about 

You don't want to scare the hell out of people who happen to hear the alarm and do not know what this is all about. I also trained my pets (cats) not to be scared by the sound by playing it once per week for some time so they get used to it.
 
## Freeing storage on the Seestar device
The scripts in this solution use strictly *read-only* access to your Seestar. It will fetch images from
the smart telescope over the network, but it will *never* delete those files. This means that the files
(usually several new files are created every minute) will slowly consume the storage space on the
Seestar device, up top the point when no new images can be taken! The storage is sufficient for several
observation nights, but you should probably make it a habit to remove the image files (see the first
entry in the FAQ below) from the device after each observation night. It is probably a good idea to move the
files to some safe storage space and keep them there for a while instead of just deleting them: once
*T Cr_B* goes nova, it might be interesting to have data available that shows what the star did in the
hours and days before the eruption.


## Managing the archived data.
The same holds for the archive space used for the pipeline's data products: once in a while you
will want to tidy up this directory (configured on the command line of the `loop.sh` script) to prevent
an excessive number of files piling up there.

## Checking for updates
You will want to occasionally check for updates of the scripts in this repository.




# FAQ


## How do I access the Seestar images remotely while it is observing?
See the tutorial in this video `https://h5.seestar.com/course/79218`



## Can I use this under Windows?
Not yet, at least not out-of-the-box. I tested this pipeline exclusively under Linux on a Raspberry Pi, 
but getting it to run under Windows should be relatively painless if you are familiar with either `Cygwin` or the `Windows Subsystem for Linux` (WSL), but both solutions will require installing additional software.
 

## Can I use this on a Linux PC other than the Raspberry Pi
Yes, that should work in principle, nothing in this project is specific to the Raspberry Pi, except the instructions given here to install the software dependencies. E.g. if you want to install to a system with x86 CPU, you need to download different files for the ASTAP sofware as described on the ASTAP website.


## How can I check that the script is actually working ok?
To make sure the alarm mechanism works, you can temporarily change the configuration 
of the thresholds that will raise the alarm. See the file Adv_Documentation.md for details 
on the format of the file `photo_ref.csv` taht contains these  settings.

You can test the playback of the alarm sound separately by executing

```./test_alarm_snd.sh```

If you do not hear any alarm sound, check the volume level set both on your (active) speakers 
connected to the Raspberry Pi and the volume level in the sound mixer application of the 
Rasperry Pi itself. 
 

## I only want to be notified when the T CrB Nova is already really bright, to be on the safe side. Should I set the alarm threshold to something like mag 6 or 5 ?
No, this is not advisable: *T CrB* is a relatively bright star even in quiescence and in the default 
configuration of the Seestar (10s exposure time for frames, gain setting at 80), there is not that much 
headroom left before the star will saturate the sensor. This means there is a limit to how bright the 
Seestar can measure the star with the software used in this solution. I would recommend to set the 
threshold to no smaller value than 8 mag.


## The script tells me that T CrB is now brightening, but when I look at the live view in the Seestar App, *T CrB* looks as bright as always. Should I go to bed again?
Careful! What you are looking at in the Seestar App is probably the *live-stacking view*, in other 
words the averaged images of the current session which might actually have started several hours ago! 
A recent change in brightness of *T CrB* will not be immediately visible in this view.
To check the validity of the alarm, you will want to check the *latest single frames* in the 
"T CrB_sub" folder on the network driver that the Seestar is exporting. They are stored there both as 
FITS and JPEG files.



