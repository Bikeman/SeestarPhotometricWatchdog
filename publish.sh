#!/bin/bash

status=`tail -n 1 work/analysis/status_summary.csv | cut -f1 -d,`

timeout -s 9 60  cp  work/analysis/checkplot.png  /media/share/www/htdocs/astro/T_CrB-latest.png
timeout -s 9 60  cp  work/analysis/status_summary.csv /media/share/www/htdocs/astro/T_CrB-latest-status.csv

timeout -s 9 60  cp  work/analysis/checkplot.png  /media/share/www/htdocs/astro/T_CrB-latest-$status.png
timeout -s 9 60  cp  work/analysis/status_summary.csv /media/share/www/htdocs/astro/T_CrB-latest-status-$status.csv



now=`date -u --iso-8601=seconds`
timeout -s 9 30  cp work/analysis/checkplot.png /media/disk1/T_CrB/archive/plot-${now}.png
timeout -s 9 30  cp work/analysis/status_summary.csv /media/disk1/T_CrB/archive/status-${now}.csv

