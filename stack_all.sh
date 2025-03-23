#!/bin/bash



rm -f work/green/*;rm -f work/*;rm -f work/inputs/*

cp inputs/*.fit work/


siril-cli -d `pwd`/work/ -s `pwd`/scr/stack_siril_1.scr
mv work/inputs/Green_* work/green
siril-cli -d `pwd`/work/green -s `pwd`/scr/stack_siril_2.scr
/opt/astap/astap_cli -f work/green/r_Green_input_stacked.fit  -r 2 -extract2 4 -log -wcs
