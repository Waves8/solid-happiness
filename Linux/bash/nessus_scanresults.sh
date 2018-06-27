#!/bin/bash
echo "Please enter token:"
read -sp 'Token: ' ntoken

curl -s -k -X GET -H "X-SecurityCenter: $ntoken" -H "Content-Type: application/json" -b sc_cookie.txt https://SECURITYCENTER/rest/scanResult?fields=name,description,status,finishTime | python -m json.tool
