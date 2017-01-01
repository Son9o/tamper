#!/bin/bash
source /usr/local/lib/bash/json.bash
source settings.sh
MyInsert="mysql -h ${MysqlHost} -u ${MysqlUser} -p${MysqlPassword} -N ${MysqlDb}"
XAuthToken="0417ec3b-af9c-40f1-8efb-4e73e45bd1ee"
#File=$(curl --compressed "https://api.gotinder.com/recs/core?locale=en" -H "platform: android" -H "User-Agent: Tinder Android Version 6.4.1" -H "os-version: 22" -H "Accept-Language: en" -H "app-version: 1935" -H "Host: api.gotinder.com" -H "Connection: Keep-Alive" -H "Accept-Encoding: gzip" -H "X-Auth-Token: ${XAuthToken}")
File=$(cat 3.dat)
FileJSON=$(echo "$File" | JSON.load)
RecsGetAmount=$(echo "${FileJSON}" | cut -d"/" -f3 | sort -nr | head -1)
typeset -i i RecsGetAmount
for ((i=0;i<=${RecsGetAmount};i++))  ;do
	RecsUserType=$(echo "$FileJSON" | grep -w "/results/${i}/type" | cut -d"\"" -f2)
	RecsUserDistanceMi=$(echo "$FileJSON" | grep -w "/results/${i}/user/distance_mi" | awk '{print $2}')
	RecsUserContentHash=$(echo "$FileJSON" | grep -w "/results/${i}/user/content_hash" | cut -d"\"" -f2)
	RecsUser_id=$(echo "$FileJSON" | grep -w "/results/${i}/user/_id" | cut -d"\"" -f2)
	RecsUser_idArray+=("RecsUser_id")
	RecsUserBio=$(echo "$FileJSON" | grep -w "/results/${i}/user/bio" | cut -d$'\t' -f2- | sed -e "s/'/' \"'\" '/g")
	RecsUserBirthDate=$(echo "$FileJSON" | grep -w "/results/${i}/user/birth_date" | cut -d"\"" -f2)
	RecsUserName=$(echo "$FileJSON" | grep -w "/results/${i}/user/name" | cut -d"\"" -f2)
	RecsUserPingTime=$(echo "$FileJSON" | grep -w "/results/${i}/user/ping_time" | cut -d"\"" -f2)
	RecsUserSNumber=$(echo "$FileJSON" | grep -w "/results/${i}/user/s_number" | awk '{print $2}')
	RecsUserPhoto0id=$(echo "$FileJSON" | grep -w "/results/${i}/user/photos/0/id" | cut -d"\"" -f2)
	RecsUserPhoto0url=$(echo "$FileJSON" | grep -w "/results/${i}/user/photos/0/url" | cut -d"\"" -f2)
	RecsUserPhoto1id=$(echo "$FileJSON" | grep -w "/results/${i}/user/photos/1/id" | cut -d"\"" -f2)
	RecsUserPhoto1url=$(echo "$FileJSON" | grep -w "/results/${i}/user/photos/1/url" | cut -d"\"" -f2)
	RecsUserPhoto2id=$(echo "$FileJSON" | grep -w "/results/${i}/user/photos/2/id" | cut -d"\"" -f2)
	RecsUserPhoto2url=$(echo "$FileJSON" | grep -w "/results/${i}/user/photos/2/url" | cut -d"\"" -f2)
	RecsUserPhoto3id=$(echo "$FileJSON" | grep -w "/results/${i}/user/photos/3/id" | cut -d"\"" -f2)
	RecsUserPhoto3url=$(echo "$FileJSON" | grep -w "/results/${i}/user/photos/3/url" | cut -d"\"" -f2)
	RecsUserPhoto4id=$(echo "$FileJSON" | grep -w "/results/${i}/user/photos/4/id" | cut -d"\"" -f2)
	RecsUserPhoto4url=$(echo "$FileJSON" | grep -w "/results/${i}/user/photos/4/url" | cut -d"\"" -f2)
	RecsUserPhoto5id=$(echo "$FileJSON" | grep -w "/results/${i}/user/photos/5/id" | cut -d"\"" -f2)
	RecsUserPhto5url=$(echo "$FileJSON" | grep -w "/results/${i}/user/photos/5/url" | cut -d"\"" -f2)
	RecsUserPhoto6id=$(echo "$FileJSON" | grep -w "/results/${i}/user/photos/6/id" | cut -d"\"" -f2)
	RecsUserPhotourl=$(echo "$FileJSON" | grep -w "/results/${i}/user/photos/6/url" | cut -d"\"" -f2)	
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
"$RecsUserPhoto6id"
"$RecsUserPhotourl""
$MyInsert <<< "INSERT INTO recs (type,distance_mi,content_hash,user_id,bio,birth_date,name,ping_time,s_number,photo0_id,photo0_url,photo1_id,photo1_url,photo2_id,photo2_url,photo3_id,photo3_url,photo4_id,photo4_url,photo5_id,photo5_url,photo6_id,photo6_url) VALUES (\"$RecsUserType\",\"$RecsUserDistanceMi\",\"$RecsUserContentHash\",\"$RecsUser_id\",'$RecsUserBio',\"$RecsUserBirthDate\",\"$RecsUserName\",\"$RecsUserPingTime\",\"$RecsUserSNumber\",\"$RecsUserPhoto0id\",\"$RecsUserPhoto0url\",\"$RecsUserPhoto1id\",\"$RecsUserPhoto1url\",\"$RecsUserPhoto2id\",\"$RecsUserPhoto2url\",\"$RecsUserPhoto3id\",\"$RecsUserPhoto3url\",\"$RecsUserPhoto4id\",\"$RecsUserPhoto4url\",\"$RecsUserPhoto5id\",\"$RecsUserPhto5url\",\"$RecsUserPhoto6id\",\"$RecsUserPhotourl\");"
done
#@x=8np?U++?zZHLX
