#!/bin/bash

target=$1
quorum_comps=$2

annotation="BETA TESTING!!"

rm work/analysis/matched_ref_photom.csv

stilts tmatch2 in1=photo_ref.csv in2=work/green/r_Green_input_stacked.csv out=work/analysis/matched_ref_photom.csv ofmt=csv \
matcher=sky \
   params=4 \
   values1='RA DEC' \
   values2='ra[0..360] dec[0..360]' \
   ocmd="addcol IMAG -2.5*log10(flux);addcol ZP REFMAG-IMAG"

stilts tpipe in="work/analysis/matched_ref_photom.csv" cmd='select equals(type,\"C\")' cmd="keepcols ZP" cmd="stats Median" out=work/analysis/med_zp.csv
ZP=`tail -n 1 work/analysis/med_zp.csv`

stilts tpipe in=work/analysis/matched_ref_photom.csv cmd="addcol MAG -2.5*log10(flux)+$ZP" \
       cmd="addcol lab toString(round(MAG*10.0))" \
       cmd="addcol MAG_IN_RANGE (MAG>=REFMAG_MIN&&MAG<=REFMAG_MAX)?\\\"OK\\\":(MAG<REFMAG_MIN?\\\"BRIGHT\\\":\\\"FAINT\\\")" \
       out=work/analysis/r_Green_input_stacked_calib_mag.csv


now=`ls -tr1 inputs/*.fit* | head -n 1 | xargs -Ixxx fitsheader xxx | grep "DATE-OBS"|cut -f2 -d\' | cut -f 1 -d.`

vmag=`egrep "^V," work/analysis/r_Green_input_stacked_calib_mag.csv  | cut -f 18 -d,`
nr_comps_ok=`egrep "^C" work/analysis/r_Green_input_stacked_calib_mag.csv  | cut -f20 -d, | grep "OK"| wc -l`
nr_comps=`egrep "^C" photo_ref.csv | wc -l`
target_status=`egrep "^V" work/analysis/r_Green_input_stacked_calib_mag.csv  | cut -f20 -d, `
if [ "X${target_status}X" = "XX" ]; then
	target_status="UNKN"
	vmag="nan"
fi

if ((nr_comps_ok >= quorum_comps)) ;then
	alarm_status=$target_status
else
	alarm_status="PHOTOM_UNCERT"
fi


# summary status message

echo "ASTATUS,VSTATUS,NRCOMP,NRCOMP_OK,TIME,VMAG,EOM" > work/analysis/status_summary.csv
echo "$alarm_status,$target_status,$nr_comps,$nr_comps_ok,$now,$vmag,1" >> work/analysis/status_summary.csv


clon=`egrep "^V" photo_ref.csv | cut -f3 -d, `
clat=`egrep "^V" photo_ref.csv | cut -f4 -d, `

stilts plot2sky \
   xpix=640 ypix=480 \
   clon=$clon clat=$clat radius=0.36 \
   title="$1 watch $now ($alarm_status) $annotation" legend=false \
   auxvisible=false \
   ifmt=CSV shading=auto \
   layer_1=Size \
      in_1=work/analysis/r_Green_input_stacked_calib_mag.csv \
      lon_1='ra[0..360]' lat_1='dec[0..360]' size_1=-MAG+16 \
      color_1=orange \
      leglabel_1='Seestar' \
   layer_2=Label \
      in_2=work/analysis/r_Green_input_stacked_calib_mag.csv \
      lon_2='ra[0..360]' lat_2='dec[0..360]' label_2=lab \
      texttype_2=antialias fontsize_2=15 color_2=black xoff_2=20 \
   layer_3=Mark \
      in_3="cat/field.cat#2" ifmt_3=fits\
      lon_3=X_WORLD lat_3=Y_WORLD \
      size_3=3 \
      leglabel_3='GSC' \
   layer_4=Label \
      in_4=work/analysis/r_Green_input_stacked_calib_mag.csv \
      lon_4='ra[0..360]' lat_4='dec[0..360]' label_4=label \
      texttype_4=antialias fontsize_4=15 color_4=blue xoff_4=20 yoff_4=15\
    out=work/analysis/checkplot.png
