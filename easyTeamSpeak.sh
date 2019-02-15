#!/bin/bash
# Author: easy (https://github.com/easy)
version="BETA 1.0"

menu=("Installieren" "Deinstallieren" "Update" "Starten" "Stoppen" "Neustarten" "Whitelist" "Blacklist" "Backup" "Einstellungen" "Abbrechen")
option=("Ja" "Nein")
versionmenu=("3.6.1 (empfohlen)" "Individuell" "Zurück")
list=("Anzeigen" "Hinzufügen" "Entfernen" "Änderungen übernehmen" "Zurück")
backup=("Anzeigen" "Erstellen" "Einspielen" "Löschen" "Zurück")
config=("Layout" "TS³-Pfad" "Einstellungen zurücksetzen" "Zurück")
layout=("Grün-Rot (Standard)" "Individuell" "Rainbow" "Zurück")

########## Default Config ##########
path="/home/TeamSpeak"
c1="\033[32m\033[1m"
c2="\033[31m\033[1m"
rainbow=""
########## Default Config ##########

header() {
	clear
	echo -e "${c1}            ${c2} ___             __               "
	echo -e "${c1} _  _   _   ${c2}  |   _  _   _  (_   _   _  _  |  "
	echo -e "${c1}(- (_| _) \/${c2}  |  (- (_| ||| __) |_) (- (_| |( "
	echo -e "${c1}          / ${c2}                    |   ${c1}$version"
}

gomenu() {
header
echo -e "${c1}Bitte wähle eine Option:${c2}"
select main in "${menu[@]}"
do
	case $main in
		"Installieren")
			install
			;;
		"Deinstallieren")
			deinstall
			;;
		"Update")
			update
			;;
		"Starten")
			start
			;;
		"Stoppen")
			stop
			;;
		"Neustarten")
			restart
			;;
		"Whitelist")
			whitelist
			;;
		"Blacklist")
			blacklist
			;;
		"Backup")
			backup
			;;
		"Einstellungen")
			config
			;;
		"Abbrechen")
			header
			echo -e "${c1}wurde beendet!"
			sleep 1
			exit 1
			;;
		*) echo "Ungültige Option: $REPLY";;
	esac
done
}

checkinstall() {
	if [ ! -d "$path" ]
		then
		header
		echo -e "${c2}Es ist kein TeamSpeak-Server installiert."
		echo -e "${c1}Soll TeamSpeak installiert werden?${c2}"
		select checkinstall in "${option[@]}"
		do
			case $checkinstall in
				"Ja")
					install
					;;
				"Nein")
					gomenu
			esac
		done
	fi
}

timer() {
	sleep 10
	(for (( i=10; i>0; i--))
	do
		sleep 1 &
		 printf "  $i \r"
		 wait
	done)
}

install() {
	if [ ! -d ${path} ]
		then
		header
		echo -e "${c1}Welche Version soll installiert werden?${c2}"
		select tsversion in "${versionmenu[@]}"
		do
			case $tsversion in
				"3.6.1 (empfohlen)")
					echo -e "${c2}TeamSpeak wird installiert. (3.6.1)${c1}"
					read -p "Bist du dir sicher? " -n 1 -r
					if [[ $REPLY =~ ^[YyJj]$ ]]
						then
						echo
						apt update
						apt upgrade -y
						mkdir ${path}
						cd ${path}
						wget https://files.teamspeak-services.com/releases/server/3.6.1/teamspeak3-server_linux_amd64-3.6.1.tar.bz2
						tar xfvj teamspeak3-server_linux_amd64-3.6.1.tar.bz2
						rm teamspeak3-server_linux_amd64-3.6.1.tar.bz2
						cd teamspeak3-server_linux_amd64
						touch .ts3server_license_accepted
						chmod 777 ts3server_startscript.sh
						./ts3server_startscript.sh start
						echo -e "${c1}TeamSpeak wurde erfolgreich unter dem Port 9987 installiert!"
						echo -e "${c2}Kopiere dir den Token und das Query Passwort."
						timer
						header
						echo -e "${c1}TeamSpeak 3.6.1 wurde erfolgreich installiert!"
						exit 1
					fi
					gomenu
					;;
				"Andere")
					echo -e "${c2}Bsp: '3.5.0' '3.5.1' '3.6.0' '3.6.1' oder neuer${c1}"
					read -p "Gib eine Version an: " versioninstall
					if [[ -z "$versioninstall" ]]
						then
						echo -e "${c2}Fehler: Keine Argumente angegeben"
						sleep 1
						install
					fi
					echo -e "${c2}TeamSpeak wird installiert. ($versioninstall)${c1}"
					read -p "Bist du dir sicher? " -n 1 -r
					if [[ $REPLY =~ ^[YyJj]$ ]]
						then
						echo
						apt update
						apt upgrade -y
						mkdir ${path}
						cd ${path}
						wget https://files.teamspeak-services.com/releases/server/$versioninstall/teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
						tar xfvj teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
						rm teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
						cd teamspeak3-server_linux_amd64
						touch .ts3server_license_accepted
						chmod 777 ts3server_startscript.sh
						./ts3server_startscript.sh start
						echo -e "${c1}TeamSpeak wurde erfolgreich unter dem Port 9987 installiert!"
						echo -e "${c2}Kopiere dir den Token und das Query Passwort."
						timer
						header
						echo -e "${c1}TeamSpeak $versioninstall wurde erfolgreich installiert!"
						exit 1
					fi
					gomenu
					;;
				"Zurück")
					gomenu
			esac
		done
	else
		header
		echo -e "${c2}TeamSpeak ist bereits installiert."
		echo -e "${c1}Soll TeamSpeak neu installiert werden?${c1}"
		select reinstall in "${option[@]}"
		do
			case $reinstall in
				"Ja")
					echo -e "${c1}Welche Version soll installiert werden?${c2}"
					select tsversion in "${versionmenu[@]}"
					do
						case $tsversion in
							"3.6.1 (empfohlen)")
								echo -e "${c2}TeamSpeak wird neu installiert. (3.6.1)${c1}"
								read -p "Bist du dir sicher? " -n 1 -r
								if [[ $REPLY =~ ^[YyJj]$ ]]
									then
									echo
									apt update
									apt upgrade -y
									cd ${path}/teamspeak3-server_linux_amd64
									./ts3server_startscript.sh stop
									rm -r -f ${path}/teamspeak3-server_linux_amd64
									cd ${path}
									wget https://files.teamspeak-services.com/releases/server/3.6.1/teamspeak3-server_linux_amd64-3.6.1.tar.bz2
									tar xfvj teamspeak3-server_linux_amd64-3.6.1.tar.bz2
									rm teamspeak3-server_linux_amd64-3.6.1.tar.bz2
									cd teamspeak3-server_linux_amd64
									touch .ts3server_license_accepted
									chmod 777 ts3server_startscript.sh
									./ts3server_startscript.sh start
									echo -e "${c1}TeamSpeak wurde erfolgreich unter dem Port 9987 installiert!"
									echo -e "${c2}Kopiere dir den Token und das Query Passwort."
									timer
									header
									echo -e "${c1}TeamSpeak 3.6.1 wurde erfolgreich neu installiert!"
									exit 1
								fi
								gomenu
								;;
							"Andere")
								echo -e "${c2}Bsp: '3.5.0' '3.5.1' '3.6.0' '3.6.1' oder neuer${c1}"
								read -p "Gib eine Version an: " versioninstall
								if [[ -z "$versioninstall" ]]
									then
									echo -e "${c2}Fehler: Keine Argumente angegeben"
									sleep 1
									install
								fi
								echo -e "${c2}TeamSpeak wird neu installiert. ($versioninstall)${c1}"
								read -p "Bist du dir sicher? " -n 1 -r
								if [[ $REPLY =~ ^[YyJj]$ ]]
									then
									echo
									apt update
									apt upgrade -y
									cd ${path}/teamspeak3-server_linux_amd64
									./ts3server_startscript.sh stop
									rm -r -f ${path}/teamspeak3-server_linux_amd64
									cd ${path}
									wget https://files.teamspeak-services.com/releases/server/$versioninstall/teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
									tar xfvj teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
									rm teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
									cd teamspeak3-server_linux_amd64
									touch .ts3server_license_accepted
									chmod 777 ts3server_startscript.sh
									./ts3server_startscript.sh start
									echo -e "${c1}TeamSpeak wurde erfolgreich unter dem Port 9987 installiert!"
									echo -e "${c2}Kopiere dir den Token und das Query Passwort."
									timer
									header
									echo -e "${c1}TeamSpeak $versioninstall wurde erfolgreich neu installiert!"
									exit 1
								fi
								gomenu
								;;
							"Zurück")
								gomenu
						esac
					done
					;;
				"Nein")
					gomenu
			esac
		done
	fi
}

deinstall() {
	echo -e "${c2}TeamSpeak wird deinstalliert.${c1}"
	read -p "Bist du dir sicher? " -n 1 -r
	if [[ $REPLY =~ ^[YyJj]$ ]]
		then
		echo
		cd $path/teamspeak3-server_linux_amd64
		./ts3server_startscript.sh stop
		rm -r -f $path
		header
		echo -e "${c1}TeamSpeak wurde erfolgreich deinstalliert!"
		sleep 1
		gomenu
	fi
	gomenu
}

update() {
	checkinstall
	echo -e "${c1}Auf welche Version soll geupdatet werden?${c2}"
	select tsversion in "${versionmenu[@]}"
	do
		case $tsversion in
			"3.6.1 (empfohlen)")
				echo -e "${c2}TeamSpeak wird geupdatet. (3.6.1)${c1}"
				read -p "Bist du dir sicher? " -n 1 -r
				if [[ $REPLY =~ ^[YyJj]$ ]]
					then
					echo
					apt update
					apt upgrade -y
					if [ ! -d "/home/easy/easyTeamSpeak/Backups" ]
						then
						mkdir /home/easy/easyTeamSpeak/Backups
					fi
					cd $path
					tar cfvj ../backups/secruity-backup.bz2 teamspeak3-server_linux_amd64/
					cd $path/teamspeak3-server_linux_amd64
					./ts3server_startscript.sh stop
					cd $path
					wget https://files.teamspeak-services.com/releases/server/3.6.1/teamspeak3-server_linux_amd64-3.6.1.tar.bz2
					tar xfvj teamspeak3-server_linux_amd64-3.6.1.tar.bz2
					rm teamspeak3-server_linux_amd64-3.6.1.tar.bz2
					cd teamspeak3-server_linux_amd64
					touch .ts3server_license_accepted
					./ts3server_startscript.sh start
					header
					echo -e "${c1}TeamSpeak wurde erfolgreich auf die 3.6.1 aktualisiert!"
					echo -e "${c1}Sicherheits-Backup unter dem Namen ${c2}{secruity-backup} ${c1}abgespeichert."
					exit 1
				fi
				gomenu
				;;
			"Individuell")
				echo -e "${c2}Bsp: '3.5.0' '3.5.1' '3.6.0' '3.6.1' oder neuer${c1}"
				read -p "Gib eine Version an: " versioninstall
				if [[ -z "$versioninstall" ]]
					then
					echo -e "${c2}Fehler: Keine Argumente angegeben"
					sleep 1
					update
				fi
				echo -e "${c2}TeamSpeak wird geupdatet. ($versioninstall)${c1}"
				read -p "Bist du dir sicher? " -n 1 -r
				if [[ -z "$versioninstall" ]]
					then
					echo
					apt update
					apt upgrade -y
					if [ ! -d "/home/easy/easyTeamSpeak/Backups" ]
						then
						mkdir /home/easy/easyTeamSpeak/Backups
					fi
					cd $path
					tar cfvj ../backups/secruity-backup.bz2 teamspeak3-server_linux_amd64/
					cd $path/teamspeak3-server_linux_amd64
					./ts3server_startscript.sh stop
					cd $path
					wget https://files.teamspeak-services.com/releases/server/$versioninstall/teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
					tar xfvj teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
					rm teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
					cd teamspeak3-server_linux_amd64
					touch .ts3server_license_accepted
					./ts3server_startscript.sh start
					header
					echo -e "${c1}TeamSpeak wurde erfolgreich auf die $versioninstall aktualisiert!"
					echo -e "${c1}Sicherheits-Backup unter dem Namen ${c2}{secruity-backup} ${c1}abgespeichert."
					exit 1
				fi
				gomenu
				;;
			"Zurück")
				gomenu
		esac
	done
}

start() {
	checkinstall
	cd $path/teamspeak3-server_linux_amd64
	./ts3server_startscript.sh start
	header
	echo -e "${c1}TeamSpeak wurde erfolgreich gestartet!"
	exit 1
}

stop() {
	checkinstall
	cd $path/teamspeak3-server_linux_amd64
	./ts3server_startscript.sh stop
	header
	echo -e "${c1}TeamSpeak wurde erfolgreich gestoppt!"
	sleep 1
	gomenu
}

restart() {
	checkinstall
	cd $path/teamspeak3-server_linux_amd64
	./ts3server_startscript.sh restart
	header
	echo -e "${c1}TeamSpeak wurde erfolgreich neugestartet!"
	exit 1
}

whitelist() {
	checkinstall
	header
	whitelist1
}

whitelist1() {
	echo -e "${c1}Bitte wähle eine Option:${c2}"
	select white in "${list[@]}"
	do
		case $white in
			"Anzeigen")
				echo -e "${c1}Alle IPs:${c2}"
				cat -A $path/teamspeak3-server_linux_amd64/query_ip_whitelist.txt
				whitelist1
				;;
			"Hinzufügen")
				echo -e "${c1}"
				read -p "Gebe eine IP an: " ip
				if [[ -z "$ip" ]]
					then
					echo -e "${c2}Fehler: Keine Argumente angegeben"
					whitelist1
				fi
				echo $ip >> $path/teamspeak3-server_linux_amd64/query_ip_whitelist.txt
				header
				echo -e "${c1}{$ip} ${c2}wurde erflogreich zur Whitelist hinzugefügt!"
				sleep 1
				whitelist
				;;
			"Entfernen")
				echo -e "${c1}"
				read -p "Gebe eine IP an: " ip
				if [[ -z "$ip" ]]
					then
					echo -e "${c2}Fehler: Keine Argumente angegeben"
					whitelist1
				fi
				sed -i "/$ip/d" $path/teamspeak3-server_linux_amd64/query_ip_whitelist.txt
				header
				echo -e "${c1}{$ip} ${c2}wurde erflogreich von der Whitelist entfernt!"
				sleep 1
				whitelist
				;;
			"Änderungen übernehmen")
				echo -e "${c2}Der TeamSpeak muss neugestartet werden."
				echo -e "${c1}Soll der TeamSpeak neugestartet werden?${c2}"
				select tsrestart in "${option[@]}"
				do
					case $tsrestart in
						"Ja")
							restart
							;;
						"Nein")
							whitelist
					esac
				done
				;;
			"Zurück")
				gomenu
		esac
	done
}

blacklist() {
	checkinstall
	header
	blacklist1
}

blacklist1() {
	checkinstall
	echo -e "${c1}Bitte wähle eine Option:${c2}"
	select white in "${list[@]}"
	do
		case $white in
			"Anzeigen")
				echo -e "${c1}Alle IPs:${c2}"
				cat -A $path/teamspeak3-server_linux_amd64/query_ip_blacklist.txt
				blacklist1
				;;
			"Hinzufügen")
				echo -e "${c1}"
				read -p "Gebe eine IP an: " ip
				if [[ -z "$ip" ]]
					then
					echo -e "${c2}Fehler: Keine Argumente angegeben"
					blacklist1
				fi
				echo $ip >> $path/teamspeak3-server_linux_amd64/query_ip_blacklist.txt
				header
				echo -e "${c1}{$ip} ${c2}wurde erflogreich zur Blacklist hinzugefügt!"
				sleep 1
				blacklist
				;;
			"Entfernen")
				echo -e "${c1}"
				read -p "Gebe eine IP an: " ip
				if [[ -z "$ip" ]]
					then
					echo -e "${c2}Fehler: Keine Argumente angegeben"
					blacklist1
				fi
				sed -i "/$ip/d" $path/teamspeak3-server_linux_amd64/query_ip_blacklist.txt
				header
				echo -e "${c1}{$ip} ${c2}wurde erflogreich von der Blacklist entfernt!"
				sleep 1
				whitelist
				;;
			"Änderungen übernehmen")
				echo -e "${c2}Der TeamSpeak muss neugestartet werden."
				echo -e "${c1}Soll der TeamSpeak neugestartet werden?${c2}"
				select tsrestart in "${option[@]}"
				do
					case $tsrestart in
						"Ja")
							restart
							;;
						"Nein")
							whitelist
					esac
				done
				;;
			"Zurück")
				gomenu
		esac
	done
}

backup() {
	header
	backup1
}

backup1() {
	echo -e "${c1}Bitte wähle eine Option:${c2}"
	select backups in "${backup[@]}"
	do
		case $backups in
			"Anzeigen")
				if [ ! -d "/home/easy/easyTeamSpeak/Backups" ]
					then
					mkdir /home/easy/easyTeamSpeak/Backups
				fi
				cd /home/easy/easyTeamSpeak/Backups
				echo -e "${c1}Alle Backups:${c2}"
				ls
				backup1
				;;
			"Erstellen")
				checkinstall
				echo -e "${c1}"
				read -p "Vergebe einen Namen: " name
				if [[ -z "$name" ]]
					then
					echo -e "${c2}Fehler: Keine Argumente angegeben"
					backup1
				fi
				if [ -f /home/easy/easyTeamSpeak/Backups/$name.bz2 ]
					then
					header
					echo -e "${c2}Das backup ${c1}{$name} ${c2}ist bereits vorhanden."
					echo -e "${c1}Soll das backup überschrieben werden?${c2}"
					select override in "${option[@]}"
					do
						case $override in
							"Ja")
								rm -f /home/easy/easyTeamSpeak/Backups/$name.bz2
								cd $path
								tar cfvj ../backups/$name.bz2 teamspeak3-server_linux_amd64/
								header
								echo -e "${c2}Das Backup ${c1}{$name} ${c2}wurde erflogreich erstellt!"
								sleep 1
								backup
								;;
							"Nein")
								backup
						esac
					done
				fi
				cd $path
				tar cfvj ../backups/$name.bz2 teamspeak3-server_linux_amd64/
				header
				echo -e "${c2}Das Backup ${c1}{$name} ${c2}wurde erflogreich erstellt!"
				sleep 1
				backup
				;;
			"Einspielen")
				echo -e "${c1}"
				read -p "Gebe den Namen des Backups an: " name
				if [[ -z "$name" ]]
					then
					echo -e "${c2}Fehler: Keine Argumente angegeben"
					backup1
				fi
				if [ ! -f /home/easy/easyTeamSpeak/Backups/$name.bz2 ]
					then
					echo -e "${c2}Backup ${c1}{$name} ${c2}konnte nicht gefunden werde."
					sleep 1
					backup
				fi
				echo -e "${c2}Backup ${c1}{$name} ${c2}wird eingespielt.${c1}"
				read -p "Bist du dir sicher? " -n 1 -r
				if [[ $REPLY =~ ^[YyJj]$ ]]
					then
					cd $path/teamspeak3-server_linux_amd64
					./ts3server_startscript.sh stop
					rm -r -f $path/teamspeak3-server_linux_amd64
					cd /home/easy/easyTeamSpeak/Backups
					tar xfvj $name.bz2
					cd
					mv /home/easy/easyTeamSpeak/Backups/teamspeak3-server_linux_amd64 $path/
					cd $path/teamspeak3-server_linux_amd64
					./ts3server_startscript.sh start
					header
					echo -e "${c2}Backup ${c1}{$name} ${c2}wurde erflogreich eingespielt!"
					exit 1
				fi
				backup
				;;
			"Löschen")
				echo -e "${c1}"
				read -p "Gebe den Namen des Backups ein: " name
				if [[ -z "$name" ]]
					then
					echo -e "${c2}Fehler: Keine Argumente angegeben"
					backup1
				fi
				if [ ! -f /home/easy/easyTeamSpeak/Backups/$name.bz2 ]
					then
					echo -e "${c2}Fehler: Backup $name nicht gefunden"
					backup1
				fi
				echo -e "${c2}Backup ${c1}{$name} ${c2}wird gelöscht.${c1}"
				read -p "Bist du dir sicher? " -n 1 -r
				if [[ $REPLY =~ ^[YyJj]$ ]]
					then
					rm -f /home/easy/easyTeamSpeak/Backups/$name.bz2
					header
					echo -e "${c2}Backup ${c1}{$name} ${c2}wurde erflogreich gelöscht!"
					sleep 1
					backup
				fi
				backup
				;;
			"Zurück")
				gomenu
		esac
	done
}

config() {
	header
	echo -e "${c1}Bitte wähle eine Option:${c2}"
	select config in "${config[@]}"
	do
		case $config in
				"Layout")
					header
					echo -e "${c1}Bitte wähle eine Option:${c2}"
					select layout in "${layout[@]}"
					do
						case $layout in
							"Grün-Rot (Standard)")
								sed -i '/c1/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
								sed -i '/c2/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
								cd
								./easyTeamSpeak.sh
								;;
							"Individuell")
								config
								;;
							"Rainbow")
								apt update
								apt upgrade -y
								apt install lolcat -y
								gem install lolcat
								sed -i '/c1/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
								sed -i '/c2/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
								echo "rainbow=|lolcat" >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
								cd
								./easyTeamSpeak.sh
								;;
							"Zurück")
								config
						esac
					done
					config
					;;
				"TS³-Pfad")
					header
					echo -e "${c1}Soll der Pfad ${c2}{$path} ${c1}geändert werden?${c2}"
					select changepath in "${option[@]}"
					do
						case $changepath in
							"Ja")
								read -p "Gebe den neuen Pfad an: " newpath
								sed -i '/path/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
								echo "path=$newpath" >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
								cd
								./easyTeamSpeak.sh
								;;
							"Nein")
								config
						esac
					done
					;;
				"Einstellungen zurücksetzen")
					read -p "Bist du dir sicher? " -n 1 -r
					if [[ $REPLY =~ ^[YyJj]$ ]]
						then
						rm /home/easy/easyTeamSpeak/easyTeamSpeak.conf
						header
						echo -e "${c1}Die Einstellungen wurden erfolgreich zurückgesetzt."
						cd
						./easyTeamSpeak.sh
					fi
					gomenu
					;;
				"Zurück")
					gomenu
		esac
	done
}

header
echo -e "${c1}Version: $version"
echo -e "${c1}by easy"
echo -e "${c1}https://github.com/easy"
echo -e "${c2}Attention! Bugs can occur. Please report this at https://github.com/easy/easyTeamSpeak"
sleep 1
#header
#echo -e "${c1}Updater${c2}"
#cd
#wget https://github.com/easy/easyTeamSpeak/archive/master.zip
#unzip master.zip
#mv /root/easyTeamSpeak-master/easyTeamSpeak.sh /root
#rm master.zip
#rm -r easyTeamSpeak-master
#chmod 777 easyTeamSpeak.sh
if [ ! -d "/home/easy" ]
	then
	mkdir /home/easy
fi
if [ ! -d "/home/easy/easyTeamSpeak" ]
	then
	mkdir /home/easy/easyTeamSpeak
fi
if [ ! -d "/home/easy/easyTeamSpeak/Backups" ]
	then
	mkdir /home/easy/easyTeamSpeak/Backups
fi
touch /home/easy/easyTeamSpeak/easyTeamSpeak.conf
source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
gomenu
