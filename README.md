# SeestarPhotometricWatchdog
A collection of simple scripts to perform on-the-fly photometry with the ZWO Seestar series telescopes in order to spot variabilities in real-time, e.g. for catching the erruption of T CrB.

For simplicity, this is intended to be run on a Raspberry Pi connected to the same network that the Seestar telescope is using, so that the code can access images generated by the Seestar via the SMB network share //Seestar/. 

This is work in progress. The intention was to get something up and running fast before T CrB errupts. The main usecase is to let the rtelescope record images as long as possible and even unattended. The code can be customized to then wake up the user or send messages out in case it detects a change in brightness that warrants human inspection.


Installing required software:
=============================

1) siril

Siril (and importantly its command line variant siril_cli) can be installed from the Raspberry Pi OS repository :

```sudo apt-get install siril```

NOTE: the script are written for the rather old version of Siril that is included in the 
Raspberry Pi OS "Bookworm" repository (at the time of writing). For newer versions, the code 
in the scr folder might need adjustments. 

2) astap
For  ASTAP and its comamnd line interface astap-cli, wee need a newer version than the one provided by the "Bookworm" repository. I suggest to follow install instruction on

At the time of writing:

```
wget https://altushost-swe.dl.sourceforge.net/project/astap-program/linux_installer/astap_armhf.deb -O astap_armhf.deb
wget https://master.dl.sourceforge.net/project/astap-program/star_databases/v50_star_database.deb -O v50_star_database.deb
wget https://master.dl.sourceforge.net/project/astap-program/linux_installer/astap_command-line_version_Linux_aarch64.zip

sudo dpkg -i astap_armhf.deb v50_star_database.deb
unzip astap_command-line_version_Linux_aarch64.zip
cp astap_cli /opt/astap/
```

3) stilts
For cross matching tables and to generate diagnostic plots, we use stilts, the command-line sister-tool of "Topcat".
This software uses JAVA and will install quite a few dependent packages, so installation might take some time.

```sudo apt-get install stilts``` 

Customizing the scripts:
========================
TODO....


Using the script:
==================
TODO: ....

