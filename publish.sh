#!/bin/bash

webdir=${1}
archive=${2}


status=`tail -n 1 work/analysis/status_summary.csv | cut -f1 -d,`

# customize to your needs for arcgiving and streaming your data to the outside word.
#
# code to interface to Home-automation (to switch on bedroom lights...) or play some
# alarm sound can also go here, e.g. play a Klaxon sound when the star is seen as brighter
# than expected, like this:


if [ "$status" = "BRIGHT" ]; then
# play klaxon sound three times in the background
   nohup ogg123 snd/klaxon.ogg snd/klaxon.ogg snd/klaxon.ogg &
fi

status=`tail -n 1 work/analysis/status_summary.csv | cut -f1 -d,`

timeout -s 9 60  cp  work/analysis/checkplot.png  $webdir/T_CrB-latest.png
timeout -s 9 60  cp  work/analysis/status_summary.csv $webdir/T_CrB-latest-status.csv

timeout -s 9 60  cp  work/analysis/checkplot.png  $webdir/T_CrB-latest-$status.png
timeout -s 9 60  cp  work/analysis/status_summary.csv $webdir/T_CrB-latest-status-$status.csv


now=`date -u --iso-8601=seconds`
timeout -s 9 30  cp work/analysis/checkplot.png $archive/plot-${now}.png
timeout -s 9 30  cp work/analysis/status_summary.csv $archive/status-${now}.csv

