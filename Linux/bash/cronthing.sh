#!/bin/bash
up_stamp="$(date +%Y%m%d%H%M)"
updatelist=/temp/"$up_stamp"_SOMENAME

if [ -f $updatelist ]
  then
    exit
fi

yum clean all && yum check-updates > $updatelist

i=${PIPESTATUS[0]}
case "$i" in
  100)
  echo "$up_stamp Updates found. >> $updatelist
  ;;
  0)
  echo "$up_stamp No updates found." >> $updatelist
  ;;
  *)
  echo "ERROR MESSAGE" >> $updatelist
  ;;
esac
