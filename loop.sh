#!/bin/bash



target=${1:-"T CrB"}
nrstack=${2:-4}
mincomps=${3:-3}
waitnewframes=${4:-120}

while [[ 1 ]] ; do

./get_files.py "$target" inputs $nrstack

if [ $? -eq 0 ]
then
  ./stack_all.sh
  ./matcher.sh "$target" $mincomps
  ./publish.sh
  echo "Digested new data at $(date -u)"
  sleep $waitnewframes
else
  sleep 60
fi
done
