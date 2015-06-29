#!/bin/bash

# Script to install and enable the latest EPEL version for your RHEL/CentOS version and architecture.
# Author: Richard Reijmers

# Some variables
EPELREPOFILE="/etc/yum.repos.d/epel.repo"
RHELVERSIONFILE="/etc/redhat-release"
RHELMAINVERSION=`egrep -o "[0-9]" ${RHELVERSIONFILE} | head -1`
ARCH=`uname -m`
EPELBASEURL="http://dl.fedoraproject.org/pub/epel/${RHELMAINVERSION}/${ARCH}/"
EPELLATESTVERSIONFILE=`links -dump ${EPELBASEURL} | grep epel-release | awk '{ print $2 }' | grep "http" | awk -F'/' '{print $8}' | sort | tail -1`

# Some pretty colors
ECHORED()       {
        echo -e "\e[1;31m${1}\e[0m"
}

ECHOYELLOW()    {
        echo -e "\e[1;33m${1}\e[0m"
}

ECHOGREEN()     {
        echo -e "\e[1;32m${1}\e[0m"
}

ECHOBLUE()      {
        echo -e "\e[1;34m${1}\e[0m"
}

# If this is not RHEL or CentOS, get the hell out
if [ ! -f ${RHELVERSIONFILE} ]
then
	ECHORED "This is not RHEL or CentOS, exiting"
	exit
fi


# Function to check if elinks is installed and install it if not present
checkElinksInstalledOrInstall() {
        if [ `rpm -qa | grep elinks | wc -l` -eq 0 ];
        then
                yum -y install elinks
        fi
}

# Function to check if EPEL repo is installed
checkEPELOrInstall()        {
        if [ `rpm -qa | grep epel | wc -l` -gt 0 ];
        then
                ECHOYELLOW "EPEL repo installed";
                # Check if any EPEL repo is enabled

                checkEPELFirstRepo

        else
                ECHORED "EPEL repo not installed";

                installEPEL

        fi
}

# Function to install EPEL
installEPEL()       {
        ECHOBLUE "Getting latest EPEL repo from ${EPELBASEURL}${EPELLATESTVERSIONFILE}"
        wget ${EPELBASEURL}${EPELLATESTVERSIONFILE} -O /root/${EPELLATESTVERSIONFILE}
        ECHOBLUE "Installing latest EPEL repo"
        rpm -Uvh /root/${EPELLATESTVERSIONFILE}
}

#function to check if the repo file's first repository has been enabled or another
checkEPELFirstRepo()        {
        if [ `grep "enabled" /etc/yum.repos.d/epel.repo | head -1 | awk -F' = ' '{print 
$2}'` -eq 1 ];
        then
                ECHOGREEN "First repository in repo file enabled"
        else
                ECHORED "First repository in repo file disabled"
                firstEnabledLine=`grep -n "enabled" /etc/yum.repos.d/epel.repo | head -1 | awk -F':' '{print $1}'`;
                ECHOBLUE "Deleting first occurence of 'enabled' from ${EPELREPOFILE} from line ${firstEnabledLine}"
                sed -i "${firstEnabledLine}d" ${EPELREPOFILE};
                ECHOBLUE "Inserting 'enabled = 1' in ${EPELREPOFILE} on line ${firstEnabledLine}"
                sed -i "${firstEnabledLine}ienabled = 1" ${EPELREPOFILE};
        fi
}


# Call da functionz
checkElinksInstalledOrInstall

checkEPELOrInstall

