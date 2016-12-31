#!/bin/bash
source /usr/local/lib/bash/json.bash
XAuthToken="0417ec3b-af9c-40f1-8efb-4e73e45bd1ee"
File=$(curl --compressed "https://api.gotinder.com/recs/core?locale=en" -H "platform: android" -H "User-Agent: Tinder Android Version 6.4.1" -H "os-version: 22" -H "Accept-Language: en" -H "app-version: 1935" -H "Host: api.gotinder.com" -H "Connection: Keep-Alive" -H "Accept-Encoding: gzip" -H "X-Auth-Token: ${XAuthToken}")

RecsGetAmount=$(echo ${File} | JSON.load | cut -d"/" -f3 | sort -nr | head -1)
typeset -i i RecsGetAmount
for ((i=0;i<=${RecsGetAmount};i++))  ;do
	echo $i
done
#@x=8np?U++?zZHLX
