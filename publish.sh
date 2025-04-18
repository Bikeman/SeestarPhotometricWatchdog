#!/bin/bash

target=${1}
webdir=${2}
archive=${3}


target_web=`echo $target | tr \\   \_ `

status=`tail -n 1 work/analysis/status_summary.csv | cut -f1 -d,`

# customize to your needs for archiving and streaming your data to the outside word.
#
# code to interface to Home-automation (to switch on bedroom lights...) or play some
# alarm sound can also go here, e.g. play a Klaxon sound when the star is seen as brighter
# than expected, like this:


if [ "$status" = "BRIGHT" ]; then
# play klaxon sound three times in the background
   nohup ogg123 snd/klaxon.ogg snd/klaxon.ogg snd/klaxon.ogg &
fi


# if star rises so fast that it saturates, the photometry status might be UNKNown
# so if the comp stars are ok  but the target star cannot be measured ==> sound alarm
# comment this out if you don't want this behaviour

if [ "$status" = "UNKN" ]; then
# play klaxon sound three times in the background
   nohup ogg123 snd/klaxon.ogg snd/klaxon.ogg snd/klaxon.ogg &
fi


# For T CrB we do not expect the star to drop dramatically in brightness, so
# we do not trigger an alarm in this case. This is to avoid false alarms when
# the brightness measuremtnt of T CrB is lower than normal by mistake rather
# than by a real drop in brightness. However, if you adapt this script for other
# targets, a drop in brightness might be exactly the thing that you are looking for,
# in that case, un-comment the following if...fi block

#if [ "$status" = "FAINT" ]; then
## play klaxon sound three times in the background
#  nohup ogg123 snd/klaxon.ogg snd/klaxon.ogg snd/klaxon.ogg &
#fi

# Try to copy data products to archive and web server

timeout -s 9 60  cp  work/analysis/checkplot.png  $webdir/${target_web}-latest.png
timeout -s 9 60  cp  work/analysis/status_summary.csv $webdir/${target_web}-latest-status.csv

timeout -s 9 60  cp  work/analysis/checkplot.png  $webdir/${target_web}-latest-$status.png
timeout -s 9 60  cp  work/analysis/status_summary.csv $webdir/${target_web}-latest-status-$status.csv


now=`date -u --iso-8601=seconds`
timeout -s 9 30  cp work/analysis/checkplot.png $archive/${target_web}-plot-${now}.png
timeout -s 9 30  cp work/analysis/status_summary.csv $archive/${target_web}-status-${now}.csv

