#!/bin/bash

read -sp 'Please enter token: ' token

curl -s -k -X GET -H "X-SecurityCenter: $token" -H 'Content-Type: application/json' -b sc_cookie.txt https://SECURITYCENTER/rest/scanResult?fields=name,description,status,finishTime | python -m json.tool

dlanswer=
while [[ "$dlanswer" -ne "1" ]]; do
  echo "Do you wish to download the results?"
  read -p '([Y]es/[N]o) ' download
  case $download in
  [yY])
    dlanswer=1
    ;;
  [nN])
    exit
    ;;
  *)
    echo "Invalid input, use Y or N."
    ;;
  esac
done

sure=
while [[ "$sure" -ne "1" ]]; do
    read -p 'Enter desired ScanID: ' scanid
    echo "$scanid"
    echo "Correct ScanID?"
    read -p '([Y]es/[N]o/[Q]uit) ' sure
    case $sure in
    [yY])
      sure=1
      curl -s -k -X POST -H "X-SecurityCenter: $token" -H 'Content-Type: application/json' -b sc_cookie.txt https://SECURITYCENTER/rest/scanResult/$scanid/download > scan_"$scanid".zip
      echo "File written to scan_$scanid.zip"
      ;;
    [nN])
      continue
      ;;
    [qQ])
      exit
      ;;
    *)
      echo "Invalid input, use Y or N or Q."
      ;;
    esac
done
