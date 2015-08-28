#!/bin/bash

# Variables initialisation
version="resetPrintingSystem v1.0 2015, Yvan Godard [godardyvan@gmail.com]"
versionOSX=$(sw_vers -productVersion | awk -F '.' '{print $(NF-1)}')
scriptDir=$(dirname "${0}")
scriptName=$(basename "${0}")
scriptNameWithoutExt=$(echo "${scriptName}" | cut -f1 -d '.')

function error () {
	echo -e "\n*** Erreur ${1} ***"
	[[ ! -z ${2} ]] && echo -e ${2}
	alldone ${1}
}

function alldone () {
	exit ${1}
}

[[ `whoami` != 'root' ]] && echo "Ce script doit être utilisé par le compte root. Utilisez 'sudo' si besoin." && exit 1

echo ""
echo "****************************** `date` ******************************"
echo "${scriptName} démarré..."
echo "sur Mac OSX version $(sw_vers -productVersion)"
echo ""

shopt -s nullglob

# suppression des PPD
lpstat -p | cut -d' ' -f2 | xargs -I{} lpadmin -x {}

# réinitialisation des paramètres par défaut
launchctl stop org.cups.cupsd 
[[ -e /etc/cups/cupsd.conf ]] && [[ -e /etc/cups/cupsd.conf.default ]] && mv /etc/cups/cupsd.conf /etc/cups/cupsd.conf.backup && cp /etc/cups/cupsd.conf.default /etc/cups/cupsd.conf
[[ -e /etc/cups/printers.conf ]] && mv /etc/cups/printers.conf /etc/cups/printers.conf.backup 
launchctl start org.cups.cupsd 

alldone 0