#!/bin/bash

echo "Please enter username:"
read -p 'Username: ' nuser

echo "Please enter password:"
read -sp 'Password: ' npass

curl -s -k -X POST -d "{\"username\":\"$nuser\",\"password\":\"$npass\"}" -c sc_cookie.txt https://SECURITYCENTER/rest/token | python -m json.tool
