#!/bin/bash

webdir=${1}
archive=${2}

status=`tail -n 1 work/analysis/status_summary.csv | cut -f1 -d,`

timeout -s 9 60  cp  work/analysis/checkplot.png  $webdir/T_CrB-latest.png
timeout -s 9 60  cp  work/analysis/status_summary.csv $webdir/T_CrB-latest-status.csv

timeout -s 9 60  cp  work/analysis/checkplot.png  $webdir/T_CrB-latest-$status.png
timeout -s 9 60  cp  work/analysis/status_summary.csv $webdir/T_CrB-latest-status-$status.csv


now=`date -u --iso-8601=seconds`
timeout -s 9 30  cp work/analysis/checkplot.png $archive/plot-${now}.png
timeout -s 9 30  cp work/analysis/status_summary.csv $archive/status-${now}.csv

