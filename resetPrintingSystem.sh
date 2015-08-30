#!/bin/bash

# Variables initialisation
version="resetPrintingSystem v1.1 2015, Yvan Godard [godardyvan@gmail.com]"
versionOSX=$(sw_vers -productVersion | awk -F '.' '{print $(NF-1)}')
scriptDir=$(dirname "${0}")
scriptName=$(basename "${0}")
scriptNameWithoutExt=$(echo "${scriptName}" | cut -f1 -d '.')
accountNotRemovePrintersQueues="root
daemon
nobody"

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

# suppression des files d'attentes CUPS pour chaque utilisateur
if [[ ! -z ${accountNotRemovePrintersQueues} ]]; then
	for user in $(dscl . list /Users | grep -v "^_"); do
		echo ${accountNotRemovePrintersQueues} | grep ${user} > /dev/null 2>&1
		if [[ $? -ne 0 ]]; then
			for printer in $(lpstat -U ${user} -a | awk '{print $1}'); do
				echo ${printer}
				lpadmin -U ${user} -x ${printer}
			done
		fi
	done
fi

# réinitialisation des paramètres par défaut
launchctl stop org.cups.cupsd 
[[ -e /etc/cups/cupsd.conf ]] && [[ -e /etc/cups/cupsd.conf.default ]] && mv /etc/cups/cupsd.conf /etc/cups/cupsd.conf.backup && cp /etc/cups/cupsd.conf.default /etc/cups/cupsd.conf
[[ -e /etc/cups/printers.conf ]] && mv /etc/cups/printers.conf /etc/cups/printers.conf.backup 
launchctl start org.cups.cupsd 

alldone 0