#!/bin/bash

####

# Script created by Luca Piccoli

####

# Aim of this script is to parse the list of installed packages
# to transform them into readable metrics for the Prometheus Node
# Exporter thanks to the --collector.textfile.directory
# more details: https://github.com/prometheus/node_exporter?tab=readme-ov-file#enabled-by-default

####

# Variables
DESTINATION_DIR="/opt/zextras/zmstat/prometheus/"

SUPPORTED_OS_ARRAY=("Ubuntu20" "Ubuntu22" "Ubuntu24" "RHEL8" "RHEL9")
OS_VERSION=""
ALL_PACKAGES="false"

# All packages or not

REPO_RHEL="zextras"
REPO_RHEL_POSTGRES="pgdg-common"
DPKG_FORMAT="'${Package} ${Version} \${Maintainer}\\n'"
M_UBUNTU="Zextras" # Maintainer of the packages for the deb packages
M_UBUNTU_POSTGRES="PostgreSQL"

######

# Check if root user

#echo -e "Checking if the script is run as root user\n"
if [ "${EUID}" -ne 0 ]; then
        echo "Error: The script must be run as root user"
        exit 1
fi

if [ ! -d "$DESTINATION_DIR" ]; then
  mkdir "$DESTINATION_DIR"
fi

if [[ -f "$DESTINATION_DIR/carbonio_packages.prom" ]]; then
	rm -f "$DESTINATION_DIR/carbonio_packages.prom"
fi		
if [[ -f "$DESTINATION_DIR/all_packages.prom" ]]; then
	rm -f "$DESTINATION_DIR/all_packages.prom"
fi

# Check OS - Populate the OS_VERSION variable

TPARSE_OS=$(grep -oP '(?<=PRETTY_NAME=").+(?=")' /etc/os-release)

#echo ${TPARSE_OS}

case $TPARSE_OS in
	"Ubuntu 20.04.6 LTS")
		OS_VERSION="${SUPPORTED_OS_ARRAY[0]}"
		;;
	"Ubuntu 22.04.5 LTS")
		OS_VERSION="${SUPPORTED_OS_ARRAY[1]}"
		;;
	"Ubuntu 24.04.2 LTS")
		OS_VERSION="${SUPPORTED_OS_ARRAY[2]}"
		;;
	"Red Hat Enterprise Linux 8.10 (Ootpa)")
		OS_VERSION="${SUPPORTED_OS_ARRAY[3]}"
		;;
	"Red Hat Enterprise Linux 9.5 (Plow)")
		OS_VERSION="${SUPPORTED_OS_ARRAY[4]}"
		;;
	*)
		echo "Error: Unsupported OS"
		;;
esac	

# echo "${OS_VERSION}"
if [ $ALL_PACKAGES == "false" ]; then
	if [[ "${OS_VERSION}" == "Ubuntu20" ]] || [[ "${OS_VERSION}" == "Ubuntu22" ]] || [[ "${OS_VERSION}" == "Ubuntu24" ]]; then
	
		dpkg-query --show -f='${Package} ${Version} ${Maintainer}\n' | grep $M_UBUNTU |  awk '{print "installed_packages{package_name=\""$1 "\", version=\""$2"\"} 1"}' > /$DESTINATION_DIR/carbonio_packages.prom
		dpkg-query --show -f='${Package} ${Version} ${Maintainer}\n' | grep $M_UBUNTU_POSTGRES |  awk '{print "installed_packages{package_name=\""$1 "\", version=\""$2"\"} 1"}' >> /$DESTINATION_DIR/carbonio_packages.prom

	elif [[ "${OS_VERSION}" == "RHEL8" ]] || [[ "${OS_VERSION}" == "RHEL9" ]]; then
	
		dnf -q repoquery --installed --queryformat '%{from_repo} %{name} %{version}' | grep $REPO_RHEL |  awk '{print "installed_packages{package_name=\""$2 "\", version=\""$3 "\"} 1"}'  > /$DESTINATION_DIR/carbonio_packages.prom
		dnf -q repoquery --installed --queryformat '%{from_repo} %{name} %{version}' | grep $REPO_RHEL_POSTGRES |  awk '{print "installed_packages{package_name=\""$2 "\", version=\""$3 "\"} 1"}' >> /$DESTINATION_DIR/carbonio_packages.prom
	fi
else
	if [[ "${OS_VERSION}" == "Ubuntu20" ]] || [[ "${OS_VERSION}" == "Ubuntu22" ]] || [[ "${OS_VERSION}" == "Ubuntu24" ]]; then
		
		dpkg-query --show -f='${Package} ${Version} ${Maintainer}\n' |  awk '{print "installed_packages{package_name=\""$1 "\", version=\""$2 "\", maintainer=\""$3 "\"} 1"}'  > /$DESTINATION_DIR/all_packages.prom

	elif [[ "${OS_VERSION}" == "RHEL8" ]] || [[ "${OS_VERSION}" == "RHEL9" ]]; then
		

		dnf -q repoquery --installed --queryformat '%{from_repo} %{name} %{version}' |  awk '{print "installed_packages{package_name=\""$2 "\", version=\""$3 "\", maintainer=\""$1 "\"} 1"}'  > /$DESTINATION_DIR/all_packages.prom


	fi
fi

