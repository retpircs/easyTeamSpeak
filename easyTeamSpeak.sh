#!/bin/bash

# Author: easy (https://github.com/easy)
version="BETA 1.0"

menu=("Installieren" "Deinstallieren" "Update" "Starten" "Stoppen" "Neustarten" "Whitelist" "Blacklist" "Backup" "Abbrechen")
option=("Ja" "Nein")
versionmenu=("3.6.1 (empfohlen)" "Andere" "Zurück")
list=("Anzeigen" "Hinzufügen" "Entfernen" "Änderungen übernehmen" "Zurück")
backup=("Anzeigen" "Erstellen" "Einspielen" "Löschen" "Zurück")

header() {
	clear
	echo -e "\033[32m\033[1m             \033[31m___             __               "
	echo -e "\033[32m\033[1m _  _   _    \033[31m |   _  _   _  (_   _   _  _  |  "
	echo -e "\033[32m\033[1m(- (_| _) \/ \033[31m |  (- (_| ||| __) |_) (- (_| |( "
	echo -e "\033[32m\033[1m          /  \033[31m                   |   \033[32m$version"
}

gomenu() {
header
echo -e "\033[32mBitte wähle eine Option:\033[31m"
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
		"Abbrechen")
			header
			echo -e "\033[32m\033[1mwurde beendet!"
			sleep 1
			exit 1
			;;
		*) echo "Ungültige Option: $REPLY";;
	esac
done
}

checkinstall() {
	if [ ! -d "/home/ts/teamspeak3-server_linux_amd64" ]
		then
		header
		echo -e "\033[31m\033[1mEs ist kein TeamSpeak-Server installiert."
		echo -e "\033[32mSoll TeamSpeak installiert werden?\033[31m"
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
	if [ ! -d /home/ts/teamspeak3-server_linux_amd64 ]
		then
		header
		echo -e "\033[32mWelche Version soll installiert werden?\033[31m"
		select tsversion in "${versionmenu[@]}"
		do
			case $tsversion in
				"3.6.1 (empfohlen)")
					echo -e "\033[31mTeamSpeak wird installiert. (3.6.1)\033[32m"
					read -p "Bist du dir sicher? " -n 1 -r
					if [[ $REPLY =~ ^[YyJj]$ ]]
						then
						echo
						apt update
						apt upgrade -y
						mkdir /home/ts
						cd /home/ts
						wget https://files.teamspeak-services.com/releases/server/3.6.1/teamspeak3-server_linux_amd64-3.6.1.tar.bz2
						tar xfvj teamspeak3-server_linux_amd64-3.6.1.tar.bz2
						rm teamspeak3-server_linux_amd64-3.6.1.tar.bz2
						cd teamspeak3-server_linux_amd64
						touch .ts3server_license_accepted
						chmod 777 ts3server_startscript.sh
						./ts3server_startscript.sh start
						echo -e "\033[32m\033[1mTeamSpeak wurde erfolgreich unter dem Port 9987 installiert!"
						echo -e "\033[31m\033[1mKopiere dir den Token und das Query Passwort."
						timer
						header
						echo -e "\033[32m\033[1mTeamSpeak 3.6.1 wurde erfolgreich installiert!"
						exit 1
					fi
					gomenu
					;;
				"Andere")
					echo -e "\033[31m\033[1mBsp: '3.5.0' '3.5.1' '3.6.0' '3.6.1' oder neuer\033[32m"
					read -p "Gib eine Version an: " versioninstall
					if [[ -z "$versioninstall" ]]
						then
						echo -e "\033[31m\033[1mFehler: Keine Argumente angegeben"
						sleep 1
						install
					fi
					echo -e "\033[31mTeamSpeak wird installiert. ($versioninstall)\033[32m"
					read -p "Bist du dir sicher? " -n 1 -r
					if [[ $REPLY =~ ^[YyJj]$ ]]
						then
						echo
						apt update
						apt upgrade -y
						mkdir /home/ts
						cd /home/ts
						wget https://files.teamspeak-services.com/releases/server/$versioninstall/teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
						tar xfvj teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
						rm teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
						cd teamspeak3-server_linux_amd64
						touch .ts3server_license_accepted
						chmod 777 ts3server_startscript.sh
						./ts3server_startscript.sh start
						echo -e "\033[32m\033[1mTeamSpeak wurde erfolgreich unter dem Port 9987 installiert!"
						echo -e "\033[31m\033[1mKopiere dir den Token und das Query Passwort."
						timer
						header
						echo -e "\033[32m\033[1mTeamSpeak $versioninstall wurde erfolgreich installiert!"
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
		echo -e "\033[31mTeamSpeak ist bereits installiert."
		echo -e "\033[32mSoll TeamSpeak neu installiert werden?\033[32m"
		select reinstall in "${option[@]}"
		do
			case $reinstall in
				"Ja")
					echo -e "\033[32mWelche Version soll installiert werden?\033[31m"
					select tsversion in "${versionmenu[@]}"
					do
						case $tsversion in
							"3.6.1 (empfohlen)")
								echo -e "\033[31mTeamSpeak wird neu installiert. (3.6.1)\033[32m"
								read -p "Bist du dir sicher? " -n 1 -r
								if [[ $REPLY =~ ^[YyJj]$ ]]
									then
									echo
									apt update
									apt upgrade -y
									cd /home/ts/teamspeak3-server_linux_amd64
									./ts3server_startscript.sh stop
									rm -r -f /home/ts/teamspeak3-server_linux_amd64
									cd /home/ts
									wget https://files.teamspeak-services.com/releases/server/3.6.1/teamspeak3-server_linux_amd64-3.6.1.tar.bz2
									tar xfvj teamspeak3-server_linux_amd64-3.6.1.tar.bz2
									rm teamspeak3-server_linux_amd64-3.6.1.tar.bz2
									cd teamspeak3-server_linux_amd64
									touch .ts3server_license_accepted
									chmod 777 ts3server_startscript.sh
									./ts3server_startscript.sh start
									echo -e "\033[32m\033[1mTeamSpeak wurde erfolgreich unter dem Port 9987 installiert!"
									echo -e "\033[31m\033[1mKopiere dir den Token und das Query Passwort."
									timer
									header
									echo -e "\033[32m\033[1mTeamSpeak 3.6.1 wurde erfolgreich neu installiert!"
									exit 1
								fi
								gomenu
								;;
							"Andere")
								echo -e "\033[31m\033[1mBsp: '3.5.0' '3.5.1' '3.6.0' '3.6.1' oder neuer\033[32m"
								read -p "Gib eine Version an: " versioninstall
								if [[ -z "$versioninstall" ]]
									then
									echo -e "\033[31m\033[1mFehler: Keine Argumente angegeben"
									sleep 1
									install
								fi
								echo -e "\033[31mTeamSpeak wird neu installiert. ($versioninstall)\033[32m"
								read -p "Bist du dir sicher? " -n 1 -r
								if [[ $REPLY =~ ^[YyJj]$ ]]
									then
									echo
									apt update
									apt upgrade -y
									cd /home/ts/teamspeak3-server_linux_amd64
									./ts3server_startscript.sh stop
									rm -r -f /home/ts/teamspeak3-server_linux_amd64
									cd /home/ts
									wget https://files.teamspeak-services.com/releases/server/$versioninstall/teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
									tar xfvj teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
									rm teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
									cd teamspeak3-server_linux_amd64
									touch .ts3server_license_accepted
									chmod 777 ts3server_startscript.sh
									./ts3server_startscript.sh start
									echo -e "\033[32m\033[1mTeamSpeak wurde erfolgreich unter dem Port 9987 installiert!"
									echo -e "\033[31m\033[1mKopiere dir den Token und das Query Passwort."
									timer
									header
									echo -e "\033[32m\033[1mTeamSpeak $versioninstall wurde erfolgreich neu installiert!"
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
	echo -e "\033[31mTeamSpeak wird deinstalliert.\033[32m"
	read -p "Bist du dir sicher? " -n 1 -r
	if [[ $REPLY =~ ^[YyJj]$ ]]
		then
		echo
		cd /home/ts/teamspeak3-server_linux_amd64
		./ts3server_startscript.sh stop
		rm -r -f /home/ts
		header
		echo -e "\033[32m\033[1mTeamSpeak wurde erfolgreich deinstalliert!"
		sleep 1
		gomenu
	fi
	gomenu
}

update() {
	checkinstall
	echo -e "\033[32mAuf welche Version soll geupdatet / gedowngradet werden?\033[31m"
	select tsversion in "${versionmenu[@]}"
	do
		case $tsversion in
			"3.6.1 (empfohlen)")
				echo -e "\033[31mTeamSpeak wird geupdatet / gedowngradet. (3.6.1)\033[32m"
				read -p "Bist du dir sicher? " -n 1 -r
				if [[ $REPLY =~ ^[YyJj]$ ]]
					then
					echo
					apt update
					apt upgrade -y
					if [ ! -d "/home/backups" ]
						then
						mkdir /home/backups
					fi
					cd /home/ts
					tar cfvj ../backups/secruity-backup.bz2 teamspeak3-server_linux_amd64/
					cd /home/ts/teamspeak3-server_linux_amd64
					./ts3server_startscript.sh stop
					cd /home/ts
					wget https://files.teamspeak-services.com/releases/server/3.6.1/teamspeak3-server_linux_amd64-3.6.1.tar.bz2
					tar xfvj teamspeak3-server_linux_amd64-3.6.1.tar.bz2
					rm teamspeak3-server_linux_amd64-3.6.1.tar.bz2
					cd teamspeak3-server_linux_amd64
					touch .ts3server_license_accepted
					./ts3server_startscript.sh start
					header
					echo -e "\033[32m\033[1mTeamSpeak wurde erfolgreich auf die 3.6.1 aktualisiert!"
					echo -e "\033[32m\033[1mSicherheits-Backup unter dem Namen \033[31m{secruity-backup} \033[32mabgespeichert."
					exit 1
				fi
				gomenu
				;;
			"Andere")
				echo -e "\033[31m\033[1mBsp: '3.5.0' '3.5.1' '3.6.0' '3.6.1' oder neuer\033[32m"
				read -p "Gib eine Version an: " versioninstall
				if [[ -z "$versioninstall" ]]
					then
					echo -e "\033[31m\033[1mFehler: Keine Argumente angegeben"
					sleep 1
					update
				fi
				echo -e "\033[31mTeamSpeak wird geupdatet / gedowngradet. ($versioninstall)\033[32m"
				read -p "Bist du dir sicher? " -n 1 -r
				if [[ -z "$versioninstall" ]]
					then
					echo
					apt update
					apt upgrade -y
					if [ ! -d "/home/backups" ]
						then
						mkdir /home/backups
					fi
					cd /home/ts
					tar cfvj ../backups/secruity-backup.bz2 teamspeak3-server_linux_amd64/
					cd /home/ts/teamspeak3-server_linux_amd64
					./ts3server_startscript.sh stop
					cd /home/ts
					wget https://files.teamspeak-services.com/releases/server/$versioninstall/teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
					tar xfvj teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
					rm teamspeak3-server_linux_amd64-$versioninstall.tar.bz2
					cd teamspeak3-server_linux_amd64
					touch .ts3server_license_accepted
					./ts3server_startscript.sh start
					header
					echo -e "\033[32m\033[1mTeamSpeak wurde erfolgreich auf die $versioninstall aktualisiert!"
					echo -e "\033[32m\033[1mSicherheits-Backup unter dem Namen \033[31m{secruity-backup} \033[32mabgespeichert."
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
	cd /home/ts/teamspeak3-server_linux_amd64
	./ts3server_startscript.sh start
	header
	echo -e "\033[32m\033[1mTeamSpeak wurde erfolgreich gestartet!"
	exit 1
}

stop() {
	checkinstall
	cd /home/ts/teamspeak3-server_linux_amd64
	./ts3server_startscript.sh stop
	header
	echo -e "\033[32m\033[1mTeamSpeak wurde erfolgreich gestoppt!"
	sleep 1
	gomenu
}

restart() {
	checkinstall
	cd /home/ts/teamspeak3-server_linux_amd64
	./ts3server_startscript.sh restart
	header
	echo -e "\033[32m\033[1mTeamSpeak wurde erfolgreich neugestartet!"
	exit 1
}

whitelist() {
	header
	whitelist1
}

whitelist1() {
	checkinstall
	echo -e "\033[32mBitte wähle eine Option:\033[31m"
	select white in "${list[@]}"
	do
		case $white in
			"Anzeigen")
				echo -e "\033[32mAlle IPs:\033[31m"
				cat -A /home/ts/teamspeak3-server_linux_amd64/query_ip_whitelist.txt
				whitelist1
				;;
			"Hinzufügen")
				echo -e "\033[32m\033[1m"
				read -p "Gebe eine IP an: " ip
				if [[ -z "$ip" ]]
					then
					echo -e "\033[31m\033[1mFehler: Keine Argumente angegeben"
					whitelist1
				fi
				echo $ip >> /home/ts/teamspeak3-server_linux_amd64/query_ip_whitelist.txt
				header
				echo -e "\033[32m{$ip} \033[31mwurde erflogreich zur Whitelist hinzugefügt!"
				sleep 1
				whitelist
				;;
			"Entfernen")
				echo -e "\033[32m\033[1m"
				read -p "Gebe eine IP an: " ip
				if [[ -z "$ip" ]]
					then
					echo -e "\033[31m\033[1mFehler: Keine Argumente angegeben"
					whitelist1
				fi
				sed -i "/$ip/d" /home/ts/teamspeak3-server_linux_amd64/query_ip_whitelist.txt
				header
				echo -e "\033[32m{$ip} \033[31mwurde erflogreich von der Whitelist entfernt!"
				sleep 1
				whitelist
				;;
			"Änderungen übernehmen")
				echo -e "\033[31m\033[1mDer TeamSpeak muss neugestartet werden."
				echo -e "\033[32m\033[1mSoll der TeamSpeak neugestartet werden?\033[31m"
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
	header
	blacklist1
}

blacklist1() {
	checkinstall
	echo -e "\033[32mBitte wähle eine Option:\033[31m"
	select white in "${list[@]}"
	do
		case $white in
			"Anzeigen")
				echo -e "\033[32mAlle IPs:\033[31m"
				cat -A /home/ts/teamspeak3-server_linux_amd64/query_ip_blacklist.txt
				blacklist1
				;;
			"Hinzufügen")
				echo -e "\033[32m\033[1m"
				read -p "Gebe eine IP an: " ip
				if [[ -z "$ip" ]]
					then
					echo -e "\033[31m\033[1mFehler: Keine Argumente angegeben"
					blacklist1
				fi
				echo $ip >> /home/ts/teamspeak3-server_linux_amd64/query_ip_blacklist.txt
				header
				echo -e "\033[32m{$ip} \033[31mwurde erflogreich zur Blacklist hinzugefügt!"
				sleep 1
				blacklist
				;;
			"Entfernen")
				echo -e "\033[32m\033[1m"
				read -p "Gebe eine IP an: " ip
				if [[ -z "$ip" ]]
					then
					echo -e "\033[31m\033[1mFehler: Keine Argumente angegeben"
					blacklist1
				fi
				sed -i "/$ip/d" /home/ts/teamspeak3-server_linux_amd64/query_ip_blacklist.txt
				header
				echo -e "\033[32m{$ip} \033[31mwurde erflogreich von der Blacklist entfernt!"
				sleep 1
				whitelist
				;;
			"Änderungen übernehmen")
				echo -e "\033[31m\033[1mDer TeamSpeak muss neugestartet werden."
				echo -e "\033[32m\033[1mSoll der TeamSpeak neugestartet werden?\033[31m"
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
	checkinstall
	header
	backup1
}

backup1() {
	echo -e "\033[32mBitte wähle eine Option:\033[31m"
	select backups in "${backup[@]}"
	do
		case $backups in
			"Anzeigen")
				if [ ! -d "/home/backups" ]
					then
					mkdir /home/backups
				fi
				cd /home/backups
				echo -e "\033[32mAlle Backups:\033[31m"
				ls
				backup1
				;;
			"Erstellen")
				echo -e "\033[32m\033[1m"
				read -p "Vergebe einen Namen: " name
				if [[ -z "$name" ]]
					then
					echo -e "\033[31m\033[1mFehler: Keine Argumente angegeben"
					backup1
				fi
				if [ ! -d "/home/backups" ]
					then
					mkdir /home/backups
				fi
				if [ -f /home/backups/$name.bz2 ]
					then
					header
					echo -e "\033[31m\033[1mDas backup \033[32m{$name} \033[31mist bereits vorhanden."
					echo -e "\033[32m\033[1mSoll das backup überschrieben werden?\033[31m"
					select override in "${option[@]}"
					do
						case $override in
							"Ja")
								rm -f /home/backups/$name.bz2
								cd /home/ts
								tar cfvj ../backups/$name.bz2 teamspeak3-server_linux_amd64/
								header
								echo -e "\033[31mDas Backup \033[32m{$name} \033[31mwurde erflogreich erstellt!"
								sleep 1
								backup
								;;
							"Nein")
								backup
						esac
					done
				fi
				cd /home/ts
				tar cfvj ../backups/$name.bz2 teamspeak3-server_linux_amd64/
				header
				echo -e "\033[31mDas Backup \033[32m{$name} \033[31mwurde erflogreich erstellt!"
				sleep 1
				backup
				;;
			"Einspielen")
				echo -e "\033[32m\033[1m"
				read -p "Gebe den Namen des Backups an: " name
				if [[ -z "$name" ]]
					then
					echo -e "\033[31m\033[1mFehler: Keine Argumente angegeben"
					backup1
				fi
				if [ ! -f /home/backups/$name.bz2 ]
					then
					echo -e "\033[31m\033[1mBackup \033[32m{$name} \033[31mkonnte nicht gefunden werde."
					sleep 1
					backup
				fi
				echo -e "\033[31m\033[1mBackup \033[32m\033[1m{$name} \033[31m\033[1mwird eingespielt.\033[32m\033[1m"
				read -p "Bist du dir sicher? " -n 1 -r
				if [[ $REPLY =~ ^[YyJj]$ ]]
					then
					cd /home/ts/teamspeak3-server_linux_amd64
					./ts3server_startscript.sh stop
					rm -r -f /home/ts/teamspeak3-server_linux_amd64
					cd /home/backups
					tar xfvj $name.bz2
					cd
					mv /home/backups/teamspeak3-server_linux_amd64 /home/ts/
					cd /home/ts/teamspeak3-server_linux_amd64
					./ts3server_startscript.sh start
					header
					echo -e "\033[31mBackup \033[32m{$name} \033[31mwurde erflogreich eingespielt!"
					exit 1
				fi
				backup
				;;
			"Löschen")
				echo -e "\033[32m\033[1m"
				read -p "Gebe den Namen des Backups ein: " name
				if [[ -z "$name" ]]
					then
					echo -e "\033[31m\033[1mFehler: Keine Argumente angegeben"
					backup1
				fi
				if [ ! -f /home/backups/$name.bz2 ]
					then
					echo -e "\033[31m\033[1mFehler: Backup $name nicht gefunden"
					backup1
				fi
				echo -e "\033[31m\033[1mBackup \033[32m\033[1m{$name} \033[31m\033[1mwird gelöscht.\033[32m\033[1m"
				read -p "Bist du dir sicher? " -n 1 -r
				if [[ $REPLY =~ ^[YyJj]$ ]]
					then
					rm -f /home/backups/$name.bz2
					header
					echo -e "\033[31mBackup \033[32m{$name} \033[31mwurde erflogreich gelöscht!"
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

header
echo -e "\033[32m\033[1mVersion: $version"
echo -e "\033[32m\033[1mby easy"
echo -e "\033[32m\033[1mhttps://github.com/easy"
echo -e "\033[31mAttention! Bugs can occur. Please report this at https://github.com/easy/easyTeamSpeak"
sleep 1
header
echo -e "\033[32m\033[1mUpdater\033[31m"
cd
wget https://github.com/easy/easyTeamSpeak/archive/master.zip
unzip master.zip
mv /root/easyTeamSpeak-master/easyTeamSpeak.sh /root
rm master.zip
rm -r easyTeamSpeak-master
chmod 777 easyTeamSpeak.sh
gomenu
