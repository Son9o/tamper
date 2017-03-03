#!/bin/bash
source /usr/local/lib/bash/json.bash
source settings.sh
function trap_error {
    echo ‘${BASH_COMMAND}‘ ended with error code ${?}, BREAKING | mail -s "tamper stopped" root@localhost
    exit 1
}
trap trap_error ERR
MyInsert="mysql -h ${MysqlHost} -u ${MysqlUser} -p${MysqlPassword} -N ${MysqlDb}"
XAuthToken="90635749-0c86-4941-8f07-d01276ab675c"
XAuthToken=$(cat xauthtoken.recent)
HostHeader="api.gotinder.com"
AppVersion="2021"
OSversion="23"
UserAgent="Tinder Android Version 6.8.1"
RetryAttempts=2
RetryAttemptsDelaySeconds=5
RandomSessionID=$(echo -n "$(date +%s)" | openssl dgst -sha1 -hmac "salted caraeml"  | awk '{print $2}')
RetryCounter=0
TimeStarted=$(date +%s)
TestCounter=0
DEBUG=0
RecsCall () 
{
	RecsResponse=$(curl --compressed "https://api.gotinder.com/recs/core?locale=en" -H "platform: android" -H "User-Agent: ${UserAgent}" -H "os-version: ${OSversion}" -H "Accept-Language: en" -H "Content-Type: application/json; charset=UTF-8" -H "app-version: ${AppVersion}" -H "Host: ${HostHeader}" -H "Connection: Keep-Alive" -H "Accept-Encoding: gzip" -H "X-Auth-Token: ${XAuthToken}")
	if [ "$RecsResponse" == '{"status":401,"error":""}' ] ;then
		echo "$(date) 401 attempt re-authentication" >> tamper.log
		((RetryCounter++))
		if [[ ${RetryCounter} -ge 3 ]] ;then
			echo "$(date) Auth Retry counter hit, breaking" >> tamper.log
			exit 1
		fi
		GetXAuthToken	
		RecsCall
	elif [ "${RecsResponse:0:23}" != '{"status":200,"results"' ] ;then
		echo "$(date) Unknown reponse: ${RecsResponse}, exiting" >> tamper.log
		exit 1
	fi
}

GetXAuthToken ()
{
	AuthResponse=$(curl --compressed -X POST "https://api.gotinder.com/v2/auth" -H "app-session: $(echo -n "$(date +%s)" | openssl dgst -sha1 -hmac "salted caraeml"  | awk '{print $2}')" -H "User-Agent: ${UserAgent}" -H "os-version: ${OSversion}" -H "app-version: ${AppVersion}" -H "platform: android" -H "Accept-Language: en" -H "Content-Type: application/json; charset=UTF-8" -H "Host: ${HostHeader}" -H "Connection: Keep-Alive" -H "Accept-Encoding: gzip" --data '{"token":"EAAGm0PX4ZCpsBACSSPW3Paq8NPsRk3FUqgjGPnmJ20Bjxl4PD1x60hyAw6CSTRCiX4Epn5QBe0j0kdX2iwjOEPogfjzeTYHBAZBkCM8qqTBSepXVpad19CDMNnFjcBzhMLya6hMc5wuh0H3WRkbZB5RoC9sx9AWrVbodYKPoZAkADiaaMA9MsBnuupWZA0I7KEPZAPMGxtqFiLQK3e2oNC","id":"734262360"}')
	if [ "${AuthResponse:0:22}" != '{"meta":{"status":200}' ] ;then
		echo "$(date)Server returned $AuthResponse" >> tamper.log
		exit 1
	else 
		XAuthToken=$(echo "$AuthResponse" | JSON.load | grep -m1 api | cut -d"\"" -f2)
		echo "$XAuthToken" > xauthtoken.recent
	fi
}

Act_array () 
{
for each in ${RecsUser_idArray[*]} ;do
	sleep $(shuf -i 1-3 -n 1)
	echo liking that sweathart
	echo $each
done
if [[ ${DEBUG} == 1 ]] ;then
	echo "array of IDs acted on"
	echo  ${RecsUser_idArray[*]}
fi
unset RecsUser_idArray
}

#Pass='curl --compressed  "https://api.gotinder.com/pass/5846770689c7f8ab55660eaf?photoId=7961acac-8e19-41ff-a33d-3a61cb4db944&content_hash=GAlhzwtLdsG6ua3t4cNAUYJTOwiEZSvPsgRtLDt92TamC5Z&s_number=263124976" -H "platform: android" -H "User-Agent: Tinder Android Version 6.4.1" -H "os-version: 22" -H "Accept-Language: en" -H "app-version: 1935" -H "Host: api.gotinder.com" -H "Connection: Keep-Alive" -H "Accept-Encoding: gzip" -H "X-Auth-Token:  ${XAuthToken}"'
#curl -v --compressed "https://api.gotinder.com/recs/core?locale=en" -H "User-Agent: Tinder Android Version 6.8.1" -H "os-version: 23" -H "app-version: 2021" -H "platform: android" -H "Accept-Language: en" -H "Content-Type: application/json; charset=UTF-8" -H "Host: api.gotinder.com" -H "Connection: Keep-Alive" -H "Accept-Encoding: gzip" -H "X-Auth-Token: 02031761-4f38-4a8c-a892-540df1b07aae"
#File=$(curl --compressed "https://api.gotinder.com/recs/core?locale=en" -H "platform: android" -H "User-Agent: Tinder Android Version 6.4.1" -H "os-version: 22" -H "Accept-Language: en" -H "app-version: 1935" -H "Host: api.gotinder.com" -H "Connection: Keep-Alive" -H "Accept-Encoding: gzip" -H "X-Auth-Token: ${XAuthToken}")
Populate ()
{
if [[ ${DEBUG} == 1 ]] ;then
	echo "Starting populate"
fi
##File means requests response  unparsed
#File=$(cat 5.dat)
#RecsResponse="${File:0:23}"
##Error handling if unknonw response stop to avoid ban, perhaps impelemnt length check
FileJSON=$(echo "${RecsResponse}" | JSON.load)
##Get number of profiles sent in recommendations
typeset -i i RecsGetAmount #make sure incremnetaor is treated as digit, should speed up the process
RecsGetAmount=$(echo "${FileJSON}" | cut -d"/" -f3 | sort -nr | head -1)
##Disembowel the load and push into DB
echo ${RecsGetAmount}
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
	RecsUserPhoto5url=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/5/url" | cut -d"\"" -f2)
#	RecsUserPhoto6id=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/6/id" | cut -d"\"" -f2)
#	RecsUserPhotourl=$(echo "$FileJSON" | grep  -w "/results/${i}/user/photos/6/url" | cut -d"\"" -f2)	
	RecsUserGender=$(echo "$FileJSON" | grep -w "/results/${i}/user/gender" |  awk '{print $2}')

	##Redeclaring variables
	declare "RecsUser${i}Type=${RecsUserType}"
	declare "RecsUser${i}DistanceMi=${RecsUserDistanceMi}"
	declare "RecsUser${i}ContentHash=${RecsUserContentHash}"
	declare "RecsUser${i}_id=${RecsUser_id}"
	declare "RecsUser${i}Bio=${RecsUserBio}"
	declare "RecsUser${i}BirthDate=${RecsUserBirthDate}"
	declare "RecsUser${i}Name=${RecsUserName}"
	declare "RecsUser${i}PingTime=${RecsUserPingTime}"
	declare "RecsUser${i}SNumber=${RecsUserSNumber}"
	declare "RecsUser${i}Photo0id=${RecsUserPhoto0id}"
	declare "RecsUser${i}Photo0url=${RecsUserPhoto0url}"
	declare "RecsUser${i}Photo1id=${RecsUserPhoto1id}"
	declare "RecsUser${i}Photo1url=${RecsUserPhoto1url}"
	declare "RecsUser${i}Photo2id=${RecsUserPhoto2id}"
	declare "RecsUser${i}Photo2url=${RecsUserPhoto2url}"
	declare "RecsUser${i}Photo3id=${RecsUserPhoto3id}"
	declare "RecsUser${i}Photo3url=${RecsUserPhoto3url}"
	declare "RecsUser${i}Photo4id=${RecsUserPhoto4id}"
	declare "RecsUser${i}Photo4url=${RecsUserPhoto4url}"
	declare "RecsUser${i}Photo5id=${RecsUserPhoto5id}"
	declare "RecsUser${i}Photo5url=${RecsUserPhoto5url}"
	declare "RecsUser${i}Gender=${RecsUserGender}"

	LikeUserResponse=$(curl --compressed "https://api.gotinder.com/like/${RecsUser_id}?photoId=${RecsUserPhoto0id}&content_hash=${RecsUserContentHash}&s_number=${RecsUserSNumber}" -H "platform: android" -H "User-Agent:  ${UserAgent}" -H "os-version: ${OSversion}" -H "Accept-Language: en" -H "app-version: ${AppVersion}" -H "Host: api.gotinder.com" -H "Connection: Keep-Alive" -H "Accept-Encoding: gzip" -H "X-Auth-Token: ${XAuthToken}")
	if [[ ${LikeUserResponse:0:43} = '{"meta":{"status":200},"data":{"api_token":' ]] ;then
		echo "$(date)[Match]Matched with ${RecsUserName} id: ${RecsUser_id}" >> tamper.log
		echo "$(date)[Match] Server returned $AuthResponse" >> tamper.log
	elif [ "${LikeUserResponse:0:15}" != '{"match":false,' ] ;then
		echo "$(date)[Liking] Server returned $AuthResponse" >> tamper.log
		exit 1
	fi
#Echo recs array
	if [[ ${DEBUG} == 1 ]] ;then
		echo "dumping converstion per id"
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
"$RecsUserPhoto5url"
"$RecsUserGender""
	fi
##DB insert
$MyInsert <<< "INSERT INTO recs (type,distance_mi,content_hash,user_id,bio,birth_date,name,ping_time,s_number,photo0_id,photo0_url,photo1_id,photo1_url,photo2_id,photo2_url,photo3_id,photo3_url,photo4_id,photo4_url,photo5_id,photo5_url,gender,date) VALUES (\"$RecsUserType\",\"$RecsUserDistanceMi\",\"$RecsUserContentHash\",\"$RecsUser_id\",'$RecsUserBio',\"$RecsUserBirthDate\",\"$RecsUserName\",\"$RecsUserPingTime\",\"$RecsUserSNumber\",\"$RecsUserPhoto0id\",\"$RecsUserPhoto0url\",\"$RecsUserPhoto1id\",\"$RecsUserPhoto1url\",\"$RecsUserPhoto2id\",\"$RecsUserPhoto2url\",\"$RecsUserPhoto3id\",\"$RecsUserPhoto3url\",\"$RecsUserPhoto4id\",\"$RecsUserPhoto4url\",\"$RecsUserPhoto5id\",\"$RecsUserPhoto5url\",\"$RecsUserGender\",NOW());"
	sleep $(shuf -i 1-3 -n 1)
done
}
Main ()
{
RecsCall
Populate
echo "Name: ${RecsUser0Name} bio: ${RecsUser0Bio}" >> usernamesbios.txdt
#Act_array
if [[ $(( $(date +%s) - ${TimeStarted} )) -ge 1800 ]] ;then
	SleepTimerH=$(shuf -i 6-8 -n 1)
	echo "$(date) Sleeping ${SleepTimerH}" >> tamper.log
	sleep ${SleepTimerH}h
	TimeStarted=$(date +%s)
fi
((TestCounter++))
#if [[ ${TestCounter} -ge 100 ]] ;then
#	echo "$(date) reached TestCounter ${TestCounter}" >> tamper.log
#	exit 1
#fi
Main
}
Main
#	curl --compressed  "https://api.gotinder.com/pass/${RecsUser_id}?photoId=${RecsUserPhoto0id}&content_hash=${RecsUserContentHash}&s_number=${RecsUserSNumber}" -H "platform: android" -H "User-Agent: Tinder Android Version 6.4.1" -H "os-version: 22" -H "Accept-Language: en" -H "app-version: 1935" -H "Host: api.gotinder.com" -H "Connection: Keep-Alive" -H "Accept-Encoding: gzip" -H "X-Auth-Token:  ${XAuthToken}""
exit 1
#@x=8np?U++?zZHLX
#curl -v --compressed -X POST "https://api.gotinder.com/v2/auth" -H "app-session: 248b0b770f30b1f747bbbe6ad0c76194c4f4ba58" -H "User-Agent: Tinder Android Version 6.8.1" -H "os-version: 23" -H "app-version: 2021" -H "platform: android" -H "Accept-Language: en" -H "Content-Type: application/json; charset=UTF-8" -H "Host: api.gotinder.com" -H "Connection: Keep-Alive" -H "Accept-Encoding: gzip" --data '{"token":"EAAGm0PX4ZCpsBACSSPW3Paq8NPsRk3FUqgjGPnmJ20Bjxl4PD1x60hyAw6CSTRCiX4Epn5QBe0j0kdX2iwjOEPogfjzeTYHBAZBkCM8qqTBSepXVpad19CDMNnFjcBzhMLya6hMc5wuh0H3WRkbZB5RoC9sx9AWrVbodYKPoZAkADiaaMA9MsBnuupWZA0I7KEPZAPMGxtqFiLQK3e2oNC","id":"734262360"}'

#curl -v --compressed "https://api.gotinder.com/recs/core?locale=en" -H "User-Agent: Tinder Android Version 6.8.1" -H "os-version: 23" -H "app-version: 2021" -H "platform: android" -H "Accept-Language: en" -H "Content-Type: application/json; charset=UTF-8" -H "Host: api.gotinder.com" -H "Connection: Keep-Alive" -H "Accept-Encoding: gzip" -H "X-Auth-Token: 02031761-4f38-4a8c-a892-540df1b07aae"
