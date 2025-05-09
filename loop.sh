#!/bin/bash


target=${1:-"T CrB"}
nrstack=${2:-4}
mincomps=${3:-3}
waitnewframes=${4:-120}
webdir=${5:-/var/www/html/T_CrB}
archive=${6:-/media/disk1/T_CrB/archive}


mkdir -p inputs
mkdir -p work/inputs
mkdir -p work/green
mkdir -p work/analysis



while [[ 1 ]] ; do

./get_files.py "$target" inputs $nrstack

if [ $? -eq 0 ]
then
  ./stack_all.sh
  ./matcher.sh "$target" $mincomps
  ./publish.sh "$target" "$webdir" "$archive"
  echo "Processed new data at $(date -u --iso-8601=seconds)"
  sleep $waitnewframes
else
  sleep 60
fi
done
