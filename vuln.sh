#!/bin/bash

#~ vuln.sh 0.1a - bop - mlcboard - datenreiter

readonly useragent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36"

scan_banner() {
	header=$(curl -I "$host" -A "$useragent" -m $timeout)
	#~ echo "$header"
	if [[ ! -z "$header" ]]; then
		server=$(echo "$header" |grep -i server |cut -d":" -f2 |xargs)
		server=${server//$'\n'/ | }
		server=$(echo "$server" |xargs -i echo "{}")
		echo "[info] $host - $server" 
		echo "$host - $server" |xargs >> found_banner.txt
	else
		echo "[info] $host - empty header or timeout" |grep --color ".*"
	fi
}

scan_mysqldumper() {
	local paths=("/" "/msd" "/mySqlDumper" "/msd1.24stable" "/msd1.24.4" "/mysqldumper" "/MySQLDumper" "/mysql" "/sql" "mysql-dumper")
	local mark="<title>MySQLDumper</title>"
	for i in "${paths[@]}"; do
		echo "http://$host$i" |grep --color "http.*"
		myurl=$(echo "http://$host$i")
		#~ echo "curl -A \"$useragent\" -L --max-redirs 5 -m $timeout -D \"$myurl\""
		myhtml=$(curl --insecure -A "$useragent" -L --max-redirs 5 -m $timeout -D - "$myurl" )
		echo "$myhtml" |grep -o "HTTP.*"
		if [[ $mythml == *"$mark"* ]];then
			echo "[FOUND] mysqldumper: $myurl" |grep --color ".*"
			echo "$myurl" >> found_mysqldumper.txt
		fi
	done
}

scan_phpmyadmin() {
	#~ dev
	local paths=("" "/phpmyadmin" "/phpMyAdmin" "/mysql" "/sql" "/myadmin" "/pma")
	local unsec=("src=\"navigation.php" "src=\"main.php" "href=\"navigation.php\"")
	local sec=("input_username" "pma_username" "pma_password")
	for p in "${paths[@]}"; do
		pmaurl=$(echo "http://${host}$p")
		echo "$pmaurl"
		html=$(curl --insecure -A "$useragent" -L --max-redirs 5 -m $timeout -D - "$pmaurl" )
		echo "$html" |grep -o "HTTP.*"
		for u in "${unsec[@]}"; do
			if [[ $html == *"$u"* ]];then
				echo "[FOUND] phpmyadmin: $pmaurl" |grep --color ".*"
				echo "$pmaurl" >> found_phpmyadmin.txt
				return 0
				break
			fi
		done
		for u in "${sec[@]}"; do
			if [[ $html == *"$u"* ]];then
				echo "[FOUND] sec phpmyadmin: $pmaurl" |grep --color ".*"
				echo "$pmaurl" >> found_phpmyadmin_login.txt
				return 0
				break
			fi
		done
	done
}

scan_jenkins(){
	echo "[start] jenkins"
}

scan_wordpress() {
	local paths=("" "/wordpress" "/wp" "/blog" "/Wordpress" "/Blog" "/cms" "/b" "/press" "/web" "/test" "/administrator" "/webblog" "/weblog")
	local marks=("wp-submit" "wp_attempt_focus()" "Powered by WordPress" "?action=lostpassword")
	for p in "${paths[@]}"; do
		wpurl=$(echo "http://${host}${p}/wp-admin")
		echo "$wpurl"
		wphtml=$(curl --insecure -A "$useragent" -L --max-redirs 5 -m $timeout -D - "$wpurl" )
		for m in "${marks[@]}"; do
			if [[ $myhtml == *"$m"* ]];then
				echo "[FOUND] Wordpress: $wpurl" |grep --color ".*"
				echo "$wpurl" >> found_wordpress.txt
				break
			fi
		done
	done
}

if echo "$1" |grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\:[0-9]{1,6}\b" > /dev/null; then
	
	readonly host="$1"
	readonly timeout="$2"
	
	echo "[check] $1"
	
	#~ # moduls to scan here!
	#~ =====
	#~ scan_banner
	scan_mysqldumper
	scan_wordpress
	scan_phpmyadmin
	
	
elif [[ -f "$1" ]]; then
	
	readonly iplist="$1"
	readonly threads="$2"
	readonly timeout="$3"
	
	count="fake"
	#~ count=$(cat "$iplist" |wc -l)
	
	echo "[input file] $iplist ($count lines)" |grep --color ".*"
	echo "[threads] $threads" |grep --color ".*"
	echo "[timeout] $timeout" |grep --color ".*"
	
	cat "$iplist" |xargs -P${threads} -i bash $0 "{}" "$timeout"
	
elif [[ -z "$1" ]]; then
	echo "[USAGE] bash $0 <iplist.txt> <threads> <timeout>" |grep --color ".*"
	echo "[zB] bash $0 iplist.txt 100 10" |grep --color ".*"
	echo "iplist.txt with ip and port zB: 127.0.0.1:8080"
	echo "vuln.sh scanner by bop²0²²"
else
	echo "[error] no legal input: $1" |grep --color ".*"
	
fi



#EOF
