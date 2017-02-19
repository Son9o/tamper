#!/bin/bash
source /usr/local/lib/bash/json.bash
source settings.sh
MyInsert="mysql -h ${MysqlHost} -u ${MysqlUser} -p${MysqlPassword} -N ${MysqlDb}"
XAuthToken="90635749-0c86-4941-8f07-d01276ab675c"
Pass='curl --compressed  "https://api.gotinder.com/pass/5846770689c7f8ab55660eaf?photoId=7961acac-8e19-41ff-a33d-3a61cb4db944&content_hash=GAlhzwtLdsG6ua3t4cNAUYJTOwiEZSvPsgRtLDt92TamC5Z&s_number=263124976" -H "platform: android" -H "User-Agent: Tinder Android Version 6.4.1" -H "os-version: 22" -H "Accept-Language: en" -H "app-version: 1935" -H "Host: api.gotinder.com" -H "Connection: Keep-Alive" -H "Accept-Encoding: gzip" -H "X-Auth-Token:  ${XAuthToken}"'
#File=$(curl --compressed "https://api.gotinder.com/recs/core?locale=en" -H "platform: android" -H "User-Agent: Tinder Android Version 6.4.1" -H "os-version: 22" -H "Accept-Language: en" -H "app-version: 1935" -H "Host: api.gotinder.com" -H "Connection: Keep-Alive" -H "Accept-Encoding: gzip" -H "X-Auth-Token: ${XAuthToken}")
##File means requests response  unparsed
File=$(cat 5.dat)
RecsResponse="${File:0:23}"
##Error handling if unknonw response stop to avoid ban, perhaps impelemnt length check
if [ "$RecsResponse" != '{"status":200,"results"' ] ;then
	echo "Unknown reponse, exiting"
	exit 1
fi
FileJSON=$(echo "$File" | JSON.load)
##Get number of profiles sent in recommendations
RecsGetAmount=$(echo "${FileJSON}" | cut -d"/" -f3 | sort -nr | head -1)
##Disembowel the load and push into DB
typeset -i i RecsGetAmount #make sure incremnetaor is treated as digit, should speed up the process
###Possibly rewrite to cut per user ID first and then look for string match which should speed up grep by not looking through the whole time every time
for ((i=0;i<=${RecsGetAmount};i++))  ;do
	RecsUserType=$(echo "$FileJSON" | grep  -w "/results/${i}/type" | cut -d"\"" -f2)
	RecsUserDistanceMi=$(echo "$FileJSON" | grep  -w "/results/${i}/user/distance_mi" | awk '{print $2}')
	RecsUserContentHash=$(echo "$FileJSON" | grep  -w "/results/${i}/user/content_hash" | cut -d"\"" -f2)
	RecsUser_id=$(echo "$FileJSON" | grep  -w "/results/${i}/user/_id" | cut -d"\"" -f2)
	RecsUser_idArray+=("${RecsUser_id}") # This Line adds user ID to araay to operate on later (pass/like/super/whatnot)
	RecsUserBio=$(echo "$FileJSON" | grep  -w "/results/${i}/user/bio" | cut -d$'\t' -f2- | sed -e "s/'/' \"'\" '/g")
	RecsUserBirthDate=$(echo "$FileJSON" | grep  -w "/results/${i}/user/birth_date" | cut -d"\"" -f2)
	RecsUserName=$(echo "$FileJSON" | grep  -w "/results/${i}/user/name" | cut -d"\"" -f2)
	RecsUserPingTime=$(echo "$FileJSON" | grep  -w "/results/${i}/user/ping_time" | cut -d"\"" -f2)
	RecsUserSNumber=$(echo "$FileJSON" | grep  -w "/results/${i}/user/s_number" | awk '{print $2}')
	RecsUserPhoto0id=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/0/id" | cut -d"\"" -f2)
	RecsUserPhoto0url=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/0/url" | cut -d"\"" -f2)
	RecsUserPhoto1id=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/1/id" | cut -d"\"" -f2)
	RecsUserPhoto1url=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/1/url" | cut -d"\"" -f2)
	RecsUserPhoto2id=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/2/id" | cut -d"\"" -f2)
	RecsUserPhoto2url=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/2/url" | cut -d"\"" -f2)
	RecsUserPhoto3id=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/3/id" | cut -d"\"" -f2)
	RecsUserPhoto3url=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/3/url" | cut -d"\"" -f2)
	RecsUserPhoto4id=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/4/id" | cut -d"\"" -f2)
	RecsUserPhoto4url=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/4/url" | cut -d"\"" -f2)
	RecsUserPhoto5id=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/5/id" | cut -d"\"" -f2)
	RecsUserPhto5url=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/5/url" | cut -d"\"" -f2)
#	RecsUserPhoto6id=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/6/id" | cut -d"\"" -f2)
#	RecsUserPhotourl=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/6/url" | cut -d"\"" -f2)	
	RecsUserGemder=$(echo  "$FileJSON" | grep -w "/results/${i}/user/gender" | cut -d"\"" -f2)

	echo $i
	echo -e "
"$RecsUserType"
"$RecsUserDistanceMi" 
"$RecsUserContentHash"
"$RecsUser_id"
"$RecsUserBio" 
"$RecsUserBirthDate" 
"$RecsUserName"
"$RecsUserPingTime" 
"$RecsUserSNumber"
"$RecsUserPhoto0id" 
"$RecsUserPhoto0url" 
"$RecsUserPhoto1id" 
"$RecsUserPhoto1url" 
"$RecsUserPhoto2id"
"$RecsUserPhoto2url" 
"$RecsUserPhoto3id" 
"$RecsUserPhoto3url" 
"$RecsUserPhoto4id"
"$RecsUserPhoto4url"
"$RecsUserPhoto5id" 
"$RecsUserPhto5url"

$MyInsert <<< "INSERT INTO recs (type,distance_mi,content_hash,user_id,bio,birth_date,name,ping_time,s_number,photo0_id,photo0_url,photo1_id,photo1_url,photo2_id,photo2_url,photo3_id,photo3_url,photo4_id,photo4_url,photo5_id,photo5_url) VALUES (\"$RecsUserType\",\"$RecsUserDistanceMi\",\"$RecsUserContentHash\",\"$RecsUser_id\",'$RecsUserBio',\"$RecsUserBirthDate\",\"$RecsUserName\",\"$RecsUserPingTime\",\"$RecsUserSNumber\",\"$RecsUserPhoto0id\",\"$RecsUserPhoto0url\",\"$RecsUserPhoto1id\",\"$RecsUserPhoto1url\",\"$RecsUserPhoto2id\",\"$RecsUserPhoto2url\",\"$RecsUserPhoto3id\",\"$RecsUserPhoto3url\",\"$RecsUserPhoto4id\",\"$RecsUserPhoto4url\",\"$RecsUserPhoto5id\",\"$RecsUserPhto5url\");"
done
#	curl --compressed  "https://api.gotinder.com/pass/${RecsUser_id}?photoId=${RecsUserPhoto0id}&content_hash=${RecsUserContentHash}&s_number=${RecsUserSNumber}" -H "platform: android" -H "User-Agent: Tinder Android Version 6.4.1" -H "os-version: 22" -H "Accept-Language: en" -H "app-version: 1935" -H "Host: api.gotinder.com" -H "Connection: Keep-Alive" -H "Accept-Encoding: gzip" -H "X-Auth-Token:  ${XAuthToken}""
exit 1
for each in ${RecsUser_idArray[*]} ;do
	sleep $(shuf -i 1-3 -n 1)
	echo liking that sweathart
	echo $each
done
unset RecsUser_idArray
echo  ${RecsUser_idArray[*]}
#@x=8np?U++?zZHLX
#curl -v --compressed -X POST "https://api.gotinder.com/v2/auth" -H "app-session: 248b0b770f30b1f747bbbe6ad0c76194c4f4ba58" -H "User-Agent: Tinder Android Version 6.8.1" -H "os-version: 23" -H "app-version: 2021" -H "platform: android" -H "Accept-Language: en" -H "Content-Type: application/json; charset=UTF-8" -H "Host: api.gotinder.com" -H "Connection: Keep-Alive" -H "Accept-Encoding: gzip" --data '{"token":"EAAGm0PX4ZCpsBACSSPW3Paq8NPsRk3FUqgjGPnmJ20Bjxl4PD1x60hyAw6CSTRCiX4Epn5QBe0j0kdX2iwjOEPogfjzeTYHBAZBkCM8qqTBSepXVpad19CDMNnFjcBzhMLya6hMc5wuh0H3WRkbZB5RoC9sx9AWrVbodYKPoZAkADiaaMA9MsBnuupWZA0I7KEPZAPMGxtqFiLQK3e2oNC","id":"734262360"}'

#curl -v --compressed "https://api.gotinder.com/recs/core?locale=en" -H "User-Agent: Tinder Android Version 6.8.1" -H "os-version: 23" -H "app-version: 2021" -H "platform: android" -H "Accept-Language: en" -H "Content-Type: application/json; charset=UTF-8" -H "Host: api.gotinder.com" -H "Connection: Keep-Alive" -H "Accept-Encoding: gzip" -H "X-Auth-Token: 02031761-4f38-4a8c-a892-540df1b07aae"
