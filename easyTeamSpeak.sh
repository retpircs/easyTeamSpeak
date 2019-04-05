#!/bin/bash
#Author: easy (https://3asy.de)
#Project page: https://3asy.de/easyTeamSpeak.html
version="BETA v0.3"

menu=("Installieren" "Deinstallieren" "Update" "Starten" "Stoppen" "Neustarten" "Whitelist" "Blacklist" "Backup" "Einstellungen" "Abbrechen")
option=("Ja" "Nein")
versionmenu=("3.7.1 (empfohlen)" "Individuell" "Zurück")
list=("Anzeigen" "Hinzufügen" "Entfernen" "Änderungen übernehmen" "Zurück")
backup=("Anzeigen" "Erstellen" "Einspielen" "Löschen" "Zurück")
config=("Layout" "TS³-Pfad" "Automatische Updates" "Manuelles Update" "Einstellungen zurücksetzen" "Zurück")
layout=("Grün-Rot (Standard)" "Individuell" "Rainbow" "Zurück")
optioncollor=("1. Farbe" "2. Farbe" "Zurück")
colors=("Schwarz" "Rot" "Grün" "Gelb" "Blau" "Magenta" "Türkis" "Weiß")

########## Default Config ##########
path="/home/TeamSpeak"
c1="\033[32m\033[1m"
c2="\033[31m\033[1m"
rainbow="false"
firstuse="true"
autoupdate="true"
########## Default Config ##########

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

message() {
	if [ "$rainbow" = true ]
		then
		echo -e "$message" | lolcat --freq=1 --seed=10
	else
		echo -e "$c1$message$c2"
	fi
}

error() {
	if [ "$rainbow" = true ]
		then
		echo -e "$c2$message\033[0m"
	else
		echo -e "$c2$message$c1"
	fi		
}

header() {
	clear
	message="            ${c2} ___             __               " && message
	message=" _  _   _   ${c2}  |   _  _   _  (_   _   _  _  |  " && message
	message="(- (_| _) \/${c2}  |  (- (_| ||| __) |_) (- (_| |( " && message
	message="          / ${c2}                    |   ${c1}$version" && message
}

gomenu() {
	header
	message="Bitte waehle eine Option:" && message
	select main in "${menu[@]}"
	do
		case $main in
			"Installieren")
				install
				;;
			"Deinstallieren")
				uninstall
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
				message="wurde beendet!" && message
				exit
		esac
	done
}

checkinstall() {
	if [ ! -d "$path" ]
		then
		header
		message="Es ist kein TeamSpeak-Server installiert." && error
		message="Soll TeamSpeak installiert werden?" && message
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
	(for (( i=15; i>0; i--))
	do
		sleep 1 &
		 printf "  $i \r"
		 wait
	done)
}

install() {
	if [ -d ${path} ]
		then
		install1
	else
		install2
	fi
}

install1() {
	header
	message="TeamSpeak ist bereits installiert." && error
	message="Soll TeamSpeak neu installiert werden?" && message
	select installoption in "${option[@]}"
	do
		case $installoption in
			"Ja")
				cd ${path}/teamspeak3-server_linux_amd64
				./ts3server_startscript.sh stop
				rm -r -f ${path}/teamspeak3-server_linux_amd64
				install2
				;;
			"Nein")
				gomenu
		esac
	done
}

install2() {
	header
	message="Welche Version soll installiert werden?" && message
	select tsversion in "${versionmenu[@]}"
	do
		case $tsversion in
			"3.7.1 (empfohlen)")
				versioninstall="3.7.1"
				install3
				;;
			"Individuell")
				message="Bsp: '3.5.0' '3.5.1' '3.6.0' '3.6.1' '3.7.0' oder neuer" && message
				read -p "Gib eine Version an: " versioninstall
				if [[ -z "$versioninstall" ]]
					then
					message="Fehler: Keine Argumente angegeben" && error
					sleep 1
					install2
				fi
				install3
				;;
			"Zurück")
				gomenu
		esac
	done
}

install3() {
	message="TeamSpeak $versioninstall wird installiert." && message
	read -p "Bist du dir sicher? " -n 1 -r
	if [[ $REPLY =~ ^[YyJj]$ ]]
		then
		apt update
		apt install bzip2
		mkdir ${path}
		cd ${path}
		wget https://files.teamspeak-services.com/releases/server/$versioninstall/teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
		tar xfvj teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
		rm teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
		cd teamspeak3-server_linux_amd64
		touch .ts3server_license_accepted
		chmod 777 ts3server_startscript.sh
		./ts3server_startscript.sh start
		sleep 5
		message="TeamSpeak wurde erfolgreich unter dem Port 9987 installiert!" && message
		message="Kopiere dir den Token und das Query Passwort, bevor der Timer abläuft." && error
		timer
		header
		message="TeamSpeak $versioninstall wurde erfolgreich installiert!" && message
		exit 1
	fi
	gomenu
}

uninstall() {
	if [ -d "$path" ]
		then
		header
		message="TeamSpeak wird deinstalliert." && message
		read -p "Bist du dir sicher? " -n 1 -r
		if [[ $REPLY =~ ^[YyJj]$ ]]
			then
			echo
			cd $path/teamspeak3-server_linux_amd64
			./ts3server_startscript.sh stop
			rm -r -f $path
			header
			message="TeamSpeak wurde erfolgreich deinstalliert!" && message
			sleep 1
			gomenu
		fi
		gomenu
	fi
	header
	message="Es ist kein TeamSpeak-Server installiert." && error
	sleep 1
	gomenu
}

update() {
	checkinstall
	header
	message="Auf welche Version soll geupdatet werden?" && message
	select tsversion in "${versionmenu[@]}"
	do
		case $tsversion in
			"3.7.1 (empfohlen)")
				versioninstall="3.7.1"
				update1
				;;
			"Individuell")
				message="Bsp: '3.5.0' '3.5.1' '3.6.0' '3.6.1' '3.7.0' oder neuer" && message
				read -p "Gib eine Version an: " versioninstall
				if [[ -z "$versioninstall" ]]
					then
					message="Fehler: Keine Argumente angegeben" && error
					sleep 1
					update1
				fi
				;;
			"Zurück")
				gomenu
		esac
	done
}

update1() {
	header
	message="TeamSpeak wird auf die Version $versioninstall geupdatet." && message
	read -p "Bist du dir sicher? " -n 1 -r
	if [[ $REPLY =~ ^[YyJj]$ ]]
		then
			apt update
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
			./ts3server_startscript.sh restart
			header
			message="TeamSpeak wurde erfolgreich auf die $versioninstall aktualisiert!" && message
			message='Ein Sicherheits-Backup wurde unter dem Namen "secruity-backup" abgespeichert.' && error
			exit 1
	fi
}

start() {
	checkinstall
	cd $path/teamspeak3-server_linux_amd64
	./ts3server_startscript.sh start
	header
	message="TeamSpeak wurde erfolgreich gestartet!" && message
	exit 1
}

stop() {
	checkinstall
	cd $path/teamspeak3-server_linux_amd64
	./ts3server_startscript.sh stop
	header
	message="TeamSpeak wurde erfolgreich gestoppt!" && message
	sleep 1
	gomenu
}

restart() {
	checkinstall
	cd $path/teamspeak3-server_linux_amd64
	./ts3server_startscript.sh restart
	header
	message="TeamSpeak wurde erfolgreich neugestartet!" && message
	exit 1
}

whitelist() {
	checkinstall
	header
	whitelist1
}

whitelist1() {
	message="Bitte waehle eine Option:" && message
	select white in "${list[@]}"
	do
		case $white in
			"Anzeigen")
				message="Alle IPs:" && message
				cat -A $path/teamspeak3-server_linux_amd64/query_ip_whitelist.txt
				whitelist1
				;;
			"Hinzufügen")
				message="Welche IP soll der Whitelist hinzugefuegt werden?" && message
				read -p "Gebe eine IP an: " ip
				if [[ -z "$ip" ]]
					then
					message="Fehler: Keine Argumente angegeben" && error
					whitelist1
				fi
				echo $ip >> $path/teamspeak3-server_linux_amd64/query_ip_whitelist.txt
				header
				message="${c2}$ip ${c1}wurde erflogreich zur Whitelist hinzugefuegt!" && message
				sleep 1
				whitelist
				;;
			"Entfernen")
				message="Welche IP soll von der Whitelist entfernt werden?" && message
				read -p "Gebe eine IP an: " ip
				if [[ -z "$ip" ]]
					then
					message="Fehler: Keine Argumente angegeben" && error
					whitelist1
				fi
				sed -i "/$ip/d" $path/teamspeak3-server_linux_amd64/query_ip_whitelist.txt
				header
				message="${c2}$ip ${c1}wurde erflogreich zur Whitelist entfernt!" && message
				sleep 1
				whitelist
				;;
			"Änderungen übernehmen")
				message="Der TeamSpeak muss neugestartet werden." && error
				message="{c1}Soll der TeamSpeak neugestartet werden?" && message
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
	message="Bitte waehle eine Option:" && message
	select white in "${list[@]}"
	do
		case $white in
			"Anzeigen")
				message="Alle IPs:" && message
				cat -A $path/teamspeak3-server_linux_amd64/query_ip_blacklist.txt
				whitelist1
				;;
			"Hinzufügen")
				message="Welche IP soll der Blacklist hinzugefuegt werden?" && message
				read -p "Gebe eine IP an: " ip
				if [[ -z "$ip" ]]
					then
					message="Fehler: Keine Argumente angegeben" && error
					whitelist1
				fi
				echo $ip >> $path/teamspeak3-server_linux_amd64/query_ip_blacklist.txt
				header
				message="${c2}$ip ${c1}wurde erflogreich zur Whitelist hinzugefuegt!" && message
				sleep 1
				whitelist
				;;
			"Entfernen")
				message="Welche IP soll von der Blacklist entfernt werden?" && message
				read -p "Gebe eine IP an: " ip
				if [[ -z "$ip" ]]
					then
					message="Fehler: Keine Argumente angegeben" && error
					whitelist1
				fi
				sed -i "/$ip/d" $path/teamspeak3-server_linux_amd64/query_ip_blacklist.txt
				header
				message="${c2}$ip ${c1}wurde erflogreich zur Whitelist entfernt!" && message
				sleep 1
				whitelist
				;;
			"Änderungen übernehmen")
				message="Der TeamSpeak muss neugestartet werden." && error
				message="{c1}Soll der TeamSpeak neugestartet werden?" && message
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
	message="Bitte waehle eine Option:" && message
	select backups in "${backup[@]}"
	do
		case $backups in
			"Anzeigen")
				if [ ! -d "/home/easy/easyTeamSpeak/Backups" ]
					then
					mkdir /home/easy/easyTeamSpeak/Backups
				fi
				cd /home/easy/easyTeamSpeak/Backups
				message="Alle Backups:" && message
				ls
				backup1
				;;
			"Erstellen")
				checkinstall
				message="Wie soll der Name des Backups lauten?" && message
				read -p "Vergebe einen Namen: " name
				if [[ -z "$name" ]]
					then
					message="Fehler: Keine Argumente angegeben" && error
					backup1
				fi
				if [ -f /home/easy/easyTeamSpeak/Backups/$name.bz2 ]
					then
					header
					message="Das backup ${c1}$name ${c2}ist bereits vorhanden." && error
					message="Soll das backup ueberschrieben werden?" && message
					select override in "${option[@]}"
					do
						case $override in
							"Ja")
								rm -f /home/easy/easyTeamSpeak/Backups/$name.bz2
								cd $path
								tar cfvj ../easy/easyTeamSpeak/Backups/$name.bz2 teamspeak3-server_linux_amd64/
								header
								message="Das Backup ${c2}$name ${c1}wurde erflogreich erstellt!" && message
								sleep 1
								backup
								;;
							"Nein")
								backup
						esac
					done
				fi
				cd $path
				tar cfvj ../easy/easyTeamSpeak/Backups/$name.bz2 teamspeak3-server_linux_amd64/
				header
				message="Das Backup ${c2}$name ${c1}wurde erflogreich erstellt!" && message
				sleep 1
				backup
				;;
			"Einspielen")
				message="Welches Backup soll eingespielt werden? (ohne .bz2)" && message
				read -p "Gebe den Namen des Backups an: " name
				if [[ -z "$name" ]]
					then
					message="Fehler: Keine Argumente angegeben" && error
					backup1
				fi
				if [ ! -f /home/easy/easyTeamSpeak/Backups/$name.bz2 ]
					then
					message="Backup ${c1}$name ${c2}konnte nicht gefunden werden." && error
					sleep 1
					backup
				fi
				message="Backup ${c2}$name ${c1}wird eingespielt." && message
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
					message="Backup ${c2}$name ${c2}wurde erflogreich eingespielt!" && message
					exit 1
				fi
				backup
				;;
			"Löschen")
				message="Welches Backup soll geloescht werden?" && message
				read -p "Gebe den Namen des Backups ein: " name
				if [[ -z "$name" ]]
					then
					message="Fehler: Keine Argumente angegeben" && error
					backup1
				fi
				if [ ! -f /home/easy/easyTeamSpeak/Backups/$name.bz2 ]
					then
					message="Fehler: Backup ${c1}$name ${c2}nicht gefunden" && error
					backup1
				fi
				message="Backup ${c2}$name ${c1}wird geloescht." && message
				read -p "Bist du dir sicher? " -n 1 -r
				if [[ $REPLY =~ ^[YyJj]$ ]]
					then
					rm -f /home/easy/easyTeamSpeak/Backups/$name.bz2
					header
					message="Backup ${c2}$name ${c2}wurde erfolgreich geloescht!" && message
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
	message="Bitte waehle eine Option:" && message
	select configmenu in "${config[@]}"
	do
		case $configmenu in
			"Layout")
				header
				message="Bitte waehle eine Option:" && message
				select layoutmenu in "${layout[@]}"
				do
					case $layoutmenu in
						"Grün-Rot (Standard)")
							sed -i '/c1/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
							sed -i '/c2/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
							sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
							c1="\033[32m\033[1m"
							c2="\033[31m\033[1m"
							rainbow="false"
							source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
							header
							message="Das Layout wurde erfolgreich geaendert." && message
							sleep 1
							gomenu
							;;
						"Individuell")
							header
							message="Bitte waehle eine Option:" && message
							select colormenu in "${optioncollor[@]}"
							do
								case $colormenu in
									"1. Farbe")
										header
										message="Bitte waehle die erste Farbe:" && message
										select color1 in "${colors[@]}"
										do
											case $color1 in
												"Schwarz")
													sed -i '/c1/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													echo 'c1="\033[30m"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													rainbow="false"
													source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													header
													message="Das Layout wurde erfolgreich geaendert." && message
													sleep 1
													config
													;;
												"Rot")
													sed -i '/c1/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													echo 'c1="\033[31m"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													rainbow="false"
													source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													header
													message="Das Layout wurde erfolgreich geaendert." && message
													sleep 1
													config
													;;
												"Grün")
													sed -i '/c1/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													echo 'c1="\033[32m"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													rainbow="false"
													source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													header
													message="Das Layout wurde erfolgreich geaendert." && message
													sleep 1
													config
													;;
												"Gelb")
													sed -i '/c1/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													echo 'c1="\033[33m"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													rainbow="false"
													source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													header
													message="Das Layout wurde erfolgreich geaendert." && message
													sleep 1
													config
													;;
												"Blau")
													sed -i '/c1/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													echo 'c1="\033[34m"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													rainbow="false"
													source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													header
													message="Das Layout wurde erfolgreich geaendert." && message
													sleep 1
													config
													;;
												"Magenta")
													sed -i '/c1/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													echo 'c1="\033[35m"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													rainbow="false"
													source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													header
													message="Das Layout wurde erfolgreich geaendert." && message
													sleep 1
													config
													;;
												"Türkis")
													sed -i '/c1/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													echo 'c1="\033[36m"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													rainbow="false"
													source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													header
													message="Das Layout wurde erfolgreich geaendert." && message
													sleep 1
													config
													;;
												"Weiß")
													sed -i '/c1/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													echo 'c1="\033[37m"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													rainbow="false"
													source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													header
													message="Das Layout wurde erfolgreich geaendert." && message
													sleep 1
													config
											esac
										done
										;;
									"2. Farbe")
										header
										message="Bitte waehle die zweite Farbe:" && message
										select color2 in "${colors[@]}"
										do
											case $color2 in
												"Schwarz")
													sed -i '/c2/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													echo 'c2="\033[30m"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													rainbow="false"
													source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													header
													message="Das Layout wurde erfolgreich geaendert." && message
													sleep 1
													config
													;;
												"Rot")
													sed -i '/c2/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													echo 'c2="\033[31m"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													rainbow="false"
													source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													header
													message="Das Layout wurde erfolgreich geaendert." && message
													sleep 1
													config
													;;
												"Grün")
													sed -i '/c2/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													echo 'c2="\033[32m"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													rainbow="false"
													source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													header
													message="Das Layout wurde erfolgreich geaendert." && message
													sleep 1
													config
													;;
												"Gelb")
													sed -i '/c2/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													echo 'c2="\033[33m"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													rainbow="false"
													source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													header
													message="Das Layout wurde erfolgreich geaendert." && message
													sleep 1
													config
													;;
												"Blau")
													sed -i '/c2/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													echo 'c2="\033[34m"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													rainbow="false"
													source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													header
													message="Das Layout wurde erfolgreich geaendert." && message
													sleep 1
													config
													;;
												"Magenta")
													sed -i '/c2/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													echo 'c2="\033[35m"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													rainbow="false"
													source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													header
													message="Das Layout wurde erfolgreich geaendert." && message
													sleep 1
													config
													;;
												"Türkis")
													sed -i '/c2/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													echo 'c2="\033[36m"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													rainbow="false"
													source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													header
													message="Das Layout wurde erfolgreich geaendert." && message
													sleep 1
													config
													;;
												"Weiß")
													sed -i '/c2/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													echo 'c2="\033[37m"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													rainbow="false"
													source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
													header
													message="Das Layout wurde erfolgreich geaendert." && message
													sleep 1
													config
											esac
										done
										;;
									"Zurück")
										config
								esac
							done
							;;
						"Rainbow")
							header
							if [ "$rainbow" = true ]
								then
								message="Dieses Layout ist bereits aktiviert." && error
								sleep 1
								config
							fi
								sed -i '/rainbow/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
								echo "rainbow=true" >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
								source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
								header
								message="Das Layout wurde erfolgreich geaendert." && message
								sleep 1
								config
							;;
						"Zurück")
							config
					esac
				done
				config
				;;
			"TS³-Pfad")
				header
				message="Soll der Pfad ${c2}$path ${c1}geaendert werden?" && message
				select changepath in "${option[@]}"
				do
					case $changepath in
						"Ja")
							message="Wie soll der neue Pfad lauten?" && message
							read -p "Gebe den neuen Pfad an: " newpath
							sed -i '/path/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
							echo "path=$newpath" >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
							source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
							header
							message="Der Pfad wurde erfolgreich geaendert." && message
							sleep 1
							config
							;;
						"Nein")
							config
					esac
				done
				;;
			"Automatische Updates")
				header
				message="Sollen automatische Updates durchgefuehrt werden?" && message
				select autoupdateoption in "${option[@]}"
				do
					case $autoupdateoption in
						"Ja")
							sed -i '/autoupdate/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
							source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
							header
							message="Ab jetzt werden automatische Updates durchgeführt." && message
							sleep 1
							config
							;;
						"Nein")
							sed -i '/autoupdate/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
							echo 'autoupdate="false"' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
							source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
							header
							message="Ab jetzt werden keine automatischen Updates mehr durchgeführt." && message
							sleep 1
							config
					esac
				done
				;;
			"Manuelles Update")
				message="Ein manuelles Update wird durchgefuehrt." && message
				read -p "Bist du dir sicher? " -n 1 -r
				if [[ $REPLY =~ ^[YyJj]$ ]]
					then
					updater
					header
					message="Das Script ist nun auf der neusten Version." && message
					sleep 1
					./easyTeamSpeak.sh
				fi
				config
				;;
			"Einstellungen zurücksetzen")
				message="Die Einstellungen werden zurueckgesetzt." && message
				read -p "Bist du dir sicher? " -n 1 -r
				if [[ $REPLY =~ ^[YyJj]$ ]]
					then
					rm /home/easy/easyTeamSpeak/easyTeamSpeak.conf
					source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
					header
					message="Die Einstellungen wurden erfolgreich zurueckgesetzt." && message
					sleep 1
					exit
				fi
				config
				;;
			"Zurück")
				gomenu
		esac
	done
}

updater() {
	header
	message="Updater" && message
	cd
	wget https://github.com/easy/easyTeamSpeak/archive/master.zip
	unzip master.zip
	mv /root/easyTeamSpeak-master/easyTeamSpeak.sh /root
	rm master.zip
	rm -r easyTeamSpeak-master
	chmod +x easyTeamSpeak.sh
}

if [ "$firstuse" = true ]
	then
	clear
	echo -e "${c1}Erste Benutzung: ${c2}Das Script wird vorbereitet."
	sleep 2
	apt update
	apt install ruby -y
	apt install gem -y
	apt install lolcat -y
	gem install lolcat -y
	apt install unzip -y
	apt update
	sed -i '/firstuse/d' /home/easy/easyTeamSpeak/easyTeamSpeak.conf
	echo 'firstuse=false' >> /home/easy/easyTeamSpeak/easyTeamSpeak.conf
	source /home/easy/easyTeamSpeak/easyTeamSpeak.conf
fi
header
message="Version: $version" && message
message="by easy (https://github.com/easy)" && message
message="Attention! Bugs can occur. Please report this at https://easy.de/#contact" && error
sleep 1
if [ "$autoupdate" = true ]
	then
	updater
fi
gomenu
