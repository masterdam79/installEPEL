#!/bin/bash

# Script to install and enable the latest RPMForge version for your RHEL/CentOS version and architecture.
# Author: Richard Reijmers

# Some variables
RPMFORGEREPOFILE="/etc/yum.repos.d/rpmforge.repo"
RHELVERSIONFILE="/etc/redrat-release"
RHELMAINVERSION=`cat /etc/redhat-release | awk -F' ' '{print $4}' | awk -F'.' '{print $1}'`
ARCH=`uname -m`
RPMFORGELATESTVERSIONFILE=`links -dump http://pkgs.repoforge.org/rpmforge-release/ | grep 
"el${RHELMAINVERSION}.rf.${ARCH}" | awk -F' ' '{ print $2 }' | grep "http" | awk -F'/' '{print 
$5}' | sort | tail -1`


# If this is not RHEL or CentOS, get the hell out
if [ ! -f ${RHELVERSIONFILE} ]
then
	ECHORED "This is not RHEL or CentOS, exiting"
	exit
fi


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


# Function to check if elinks is installed and install it if not present
checkElinksInstalledOrInstall() {
        if [ `rpm -qa | grep elinks | wc -l` -eq 0 ];
        then
                yum -y install elinks
        fi
}

# Function to check if RPMForge repo is installed
checkRpmForgeOrInstall()        {
        if [ `rpm -qa | grep rpmforge | wc -l` -gt 0 ];
        then
                ECHOYELLOW "RPMForge repo installed";
                # Check if any RPMForge repo is enabled

                checkRpmForgeFirstRepo

        else
                ECHORED "RPMForge repo not installed";

                installRpmForge

        fi
}

# Function to install RPMForge
installRpmForge()       {
        ECHOBLUE "Getting latest RPMForge repo"
        wget http://pkgs.repoforge.org/rpmforge-release/${RPMFORGELATESTVERSIONFILE} -O 
/root/${RPMFORGELATESTVERSIONFILE}
        ECHOBLUE "Installing latest RPMForge repo"
        yum -y localinstall ${RPMFORGELATESTVERSIONFILE}
}

#function to check if the repo file's first repository has been enabled or another
checkRpmForgeFirstRepo()        {
        if [ `grep "enabled" /etc/yum.repos.d/rpmforge.repo | head -1 | awk -F' = ' '{print 
$2}'` -eq 1 ];
        then
                ECHOGREEN "First repository in repo file enabled"
        else
                ECHORED "First repository in repo file disabled"
                firstEnabledLine=`grep -n "enabled" /etc/yum.repos.d/rpmforge.repo | head -1 | 
awk -F':' '{print $1}'`;
                ECHOBLUE "Deleting first occurence of 'enabled' from ${RPMFORGEREPOFILE} from 
line ${firstEnabledLine}"
                sed -i "${firstEnabledLine}d" ${RPMFORGEREPOFILE};
                ECHOBLUE "Inserting 'enabled = 1' in ${RPMFORGEREPOFILE} on line 
${firstEnabledLine}"
                sed -i "${firstEnabledLine}ienabled = 1" ${RPMFORGEREPOFILE};
        fi
}


# Call da functionz
checkElinksInstalledOrInstall

checkRpmForgeOrInstall

checkRpmForgeIncludePkgs


