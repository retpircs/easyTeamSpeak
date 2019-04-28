#!/bin/bash
#Author: easy (https://3asy.de)
#Project-Site: /

oldfile="easyTeamSpeak.sh"
newfile="easyTeamSpeak.sh.x"
download="https://3asy.de/download/easyTeamSpeak/easyTeamSpeak.sh.x"

menu=("Ja" "Nein")

clear
echo -e "\033[0m-----------------------------------------------------------------"
echo ""
echo -e "\033[1m\033[31m █████╗  ██████╗██╗  ██╗████████╗██╗   ██╗███╗   ██╗ ██████╗ ██╗"
echo -e "\033[1m\033[31m██╔══██╗██╔════╝██║  ██║╚══██╔══╝██║   ██║████╗  ██║██╔════╝ ██║"
echo -e "\033[1m\033[31m███████║██║     ███████║   ██║   ██║   ██║██╔██╗ ██║██║  ███╗██║"
echo -e "\033[1m\033[31m██╔══██║██║     ██╔══██║   ██║   ██║   ██║██║╚██╗██║██║   ██║╚═╝"
echo -e "\033[1m\033[31m██║  ██║╚██████╗██║  ██║   ██║   ╚██████╔╝██║ ╚████║╚██████╔╝██╗"
echo -e "\033[1m\033[31m╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚═╝ "
echo ""
echo -e "\033[0m-----------------------------------------------------------------"
echo ""
echo -e "\033[1m\033[32mDieses Script ist veraltet!"
echo -e "\033[1m\033[32mEine neue Version wird benötigt."
echo ""
echo -e "\033[1m\033[31mSoll die neue Version installiert werden?\033[1m\033[32m"
select menu in "${menu[@]}"
do
	case $menu in
		"Ja")
			cd
			rm -r -f /home/easy/easyTeamSpeak
			rm $oldfile
			wget $download
			chmod +x $newfile
			./$newfile
			;;
		"Nein")
			echo -e "\033[0m"
			exit 1
	esac
done
