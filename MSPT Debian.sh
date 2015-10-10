#!/bin/bash
#################################################################
# Title: Install and Configure Media Apps
# Author: tscrip <github.com/tscrip>
# Purpose: Interactive script to automate installing all media
#      --> apps and system requirements.
#      --> Support Platforms: Ubuntu and RHEL(coming soon)
# ------------------------------------------------------------- #
# Change Log
# ------------------------------------------------------------- #
# tscrip -  9/8/15  - Script created
# tscrip -  9/10/15 - Removed RHEL/Fedora compatibility for complexity issues
# tscrip -  9/12/15 - Removed HTPCManager due to stablility problems
#################################################################
# Help
# ------------------------------------------------------------- #
# Sickbeard Port:       8081
# SickRage Port:        8081
# Headphones Port:      8181
# Plex Port:            32400
# Transmission Port:    9091
#################################################################

#Printing welcome screen
printf "##################################################\n"
printf "##### Welcome to the Media Server Setup Tool #####\n"
printf "#####           Created by tscrip            #####\n"
printf "##################################################\n\n"

#Defining path constants
WHIPTAIL_PATH=$(which whiptail)
GIT_PATH=$(which git)
DPKG_PATH=$(which dpkg)
# RPM_PATH=$(which rpm) Renabling when RHEL support is added
PIP_PATH=$(which pip)

####
#Installs CONSTANTS
####

#Plex
PLEX_DEB_INSTALL_64="wget https://downloads.plex.tv/plex-media-server/0.9.12.11.1406-8403350/plexmediaserver_0.9.12.11.1406-8403350_amd64.deb -O /tmp/MSPT/plex.deb"
PLEX_DEB_INSTALL_32="wget https://downloads.plex.tv/plex-media-server/0.9.12.11.1406-8403350/plexmediaserver_0.9.12.11.1406-8403350_i386.deb -O /tmp/MSPT/plex.deb"

#Transmission
TRANSMISSION_DEB_INSTALL="apt-get --assume-yes install transmission-daemon"

#Sickbeard
SICKBEARD_INSTALL="git clone https://github.com/midgetspy/Sick-Beard.git /opt/sickbeard"

#SickRage
SICKRAGE_INSTALL="git clone https://github.com/SiCKRAGETV/SickRage.git /opt/sickrage"

#CouchPotato
COUCHPOTATO_INSTALL="git clone https://github.com/RuudBurger/CouchPotatoServer.git /opt/couchpotato"

#Headphones
HEADPHONES_INSTALL="git clone https://github.com/rembo10/headphones.git /opt/headphones"

#Defining variables
whiptailInstalled=false
gitInstalled=false
basePackageInstalled=false
#distType=""

### Renabling when RHEL support is added ###

#Verifying supported platform
#if [[ -n DPKG_PATH ]]; then
#    #System must be Debian based
#    distType="debian" 
#
#elif [[ -n RPM_PATH ]]; then 
#    #System has RPM loaded
#
#    #Identifying CentOS/Fedora/RHEL
#    if [[ -n $(uname -a | grep Fedora) ]]; then
#        #System appears to be Fedora
#        distType="fedora"
#      
#    elif [[ -n $(uname -a |grep -i 'CentOS\|RedHat\|RHEL') ]]; then
#        #System appears to some version of RHEL
#        
#        distType="rhel"
#   fi
#else
#    #Could not identify system type
#    echo "Distro not supported. Please contact developer to investigate."
#    
#    #Exiting
#    exit
#fi

####
#Functions
####

#Wait for user input function
pause(){
 read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n'
}

#Base Function
function BaseFunction {
   printf "Installing Base Components\n"

   #Installing python cheetah module via pip
   pip install cheetah

   #Creating group
   groupadd mediaApps
   
   #Creating temp directory
   mkdir /tmp/MSPT
   
   printf "##Installed Base Components##\n\n"
}

#Install Transmission-cli
function InstallTransmission {
    printf "Installing Transmission\n"
    
    #Checking if Base package is loaded
    if [[ "$basePackageInstalled" = false ]]; then
    	BaseFunction

    	#Setting BaseInstalled flag to true
    	basePackageInstalled=true
    fi
    
    #Installing Transmission via dpkg
    $TRANSMISSION_DEB_INSTALL
    
    #Changing debian-transmission primary group to new group
    usermod -g mediaApps debian-transmission

    #Stopping Transmission service
    service transmission-daemon stop

    #Changing RPC whitelist
    sed -i -e 's/\"rpc-whitelist-enabled\": true/\"rpc-whitelist-enabled\": false/g' /etc/transmission-daemon/settings.json

    #Starting Transmission service 
    service transmission-daemon start

    printf "##Transmission Installed##\n\n"
}

#Install Sickbeard
function InstallSickbeard {
    printf "Installing Sickbeard\n"

    #Checking if Base package is loaded
    if [[ "$basePackageInstalled" == false ]]; then
    	BaseFunction

    	#Setting BaseInstalled flag to true
    	basePackageInstalled=true
    fi

    #Installing Sickbeard
    $SICKBEARD_INSTALL

    #Installing service account
    useradd --system --no-create-home --no-user-group -d /opt/sickbeard -G mediaApps sickbeard

    #Copying init script over
    cp /opt/sickbeard/init.ubuntu /etc/init.d/sickbeard

    #Making init.d script executable
    chmod +x /etc/init.d/sickbeard

    #Enabling init.d script
    update-rc.d sickbeard defaults

    #Creating default config
    touch /etc/default/sickbeard

    #Changing ownership of directory
    chown sickbeard:mediaApps -R /opt/sickbeard

    printf "##Sickbeard Installed##\n\n"
}

#Install SickRage
function InstallSickRage {
    printf "Installing SickRage\n"

    #Checking if Base package is loaded
    if [[ "$basePackageInstalled" == false ]]; then
    	BaseFunction

    	#Setting BaseInstalled flag to true
    	basePackageInstalled=true
    fi

    #Installing SickRage
    $SICKRAGE_INSTALL

    #Installing service account
    useradd --system --no-create-home --no-user-group -d /opt/sickrage -G mediaApps sickrage

    #Copying init script over
    cp /opt/sickrage/runscripts/init.ubuntu /etc/init.d/sickrage

    #Making init.d script executable
    chmod +x /etc/init.d/sickrage

    #Enabling init.d script
    update-rc.d sickrage defaults

    #Creating default config
    touch /etc/default/sickrage

    #Changing ownership of directory
    chown sickrage:mediaApps -R /opt/sickrage

    printf "##SickRage Installed##\n\n"
}

#Install Couchpotato
function InstallCouchPotato {
    printf "Installing CouchPotato\n"

    #Checking if Base package is loaded
    if [[ "$basePackageInstalled" == false ]]; then
    	BaseFunction

    	#Setting BaseInstalled flag to true
    	basePackageInstalled=true
    fi
    
    #Installing Couch Potato
    $COUCHPOTATO_INSTALL

    #Installing service account
    useradd --system --no-create-home --no-user-group -d /opt/couchpotato -G mediaApps couchpotato

    #Copying init script over
    cp /opt/couchpotato/init/ubuntu /etc/init.d/couchpotato

    #Making init.d script executable
    chmod +x /etc/init.d/couchpotato

    #Enabling init.d script
    update-rc.d couchpotato defaults

    #Creating default config
    touch /etc/default/couchpotato

    #Changing ownership of directory
    chown couchpotato:mediaApps -R /opt/couchpotato

    printf "##CouchPotato Installed##\n\n" 
}

#Install Headphones
function InstallHeadphones {
    printf "Installing Headphones\n"

    #Checking if Base package is loaded
    if [[ "$basePackageInstalled" == false ]]; then
    	BaseFunction

    	#Setting BaseInstalled flag to true
    	basePackageInstalled=true
    fi

    #Installing Sickbeard Torrent
    $HEADPHONES_INSTALL

    #Installing service account
    useradd --system --no-create-home --no-user-group -d /opt/headphones -G mediaApps headphones

    #Copying init script over
    cp /opt/headphones/init-scripts/init.ubuntu /etc/init.d/headphones

    #Making init.d script executable
    chmod +x /etc/init.d/headphones

    #Enabling init.d script
    update-rc.d headphones defaults

    #Creating default config
    touch /etc/default/headphones

    #Changing ownership of directory
    chown headphones:mediaApps -R /opt/headphones

    printf "##Headphones Installed##\n\n"

    #In order to access for outside localhost, you may need to run the following commands again manually:
    service headphones stop
    sed -i -e 's/http_host \= localhost/http_host \= 0.0.0.0/g' /opt/headphones/config.ini
    service headphones start
}

#Install Plex
function InstallPlex {
    printf "Installing Plex\n"

    #Checking if Base package is loaded
    if [[ "$basePackageInstalled" == false ]]; then
    	BaseFunction

    	#Setting BaseInstalled flag to true
    	basePackageInstalled=true
    fi
    
    #Finding architecture
    if [[ $(uname -m) == "x86_64" ]]; then
        
        #Getting 64bit deb
        $PLEX_DEB_INSTALL_64
    else

        #Getting 32bit deb
        $PLEX_DEB_INSTALL_32
    fi

    #Installing deb
    dpkg -i /tmp/MSPT/plex.deb

    #Adding group to Plex
    usermod -G mediaApps plex

    printf "##Plex Installed##\n\n"
}

#Install HTPCManager
function InstallHTPCManager {
    printf "Installing HTPCManager\n"

    #Checking if Base package is loaded
    if [[ "$basePackageInstalled" == false ]]; then
    	BaseFunction

    	#Setting BaseInstalled flag to true
    	basePackageInstalled=true
    fi

    #Installing HTPCManager
    $HTPCMANAGER_INSTALL

    #Installing service account
    useradd --system --no-create-home --no-user-group -d /opt/htpcmanager -G mediaApps htpcmanager

    #Copying init script over
    cp /opt/htpcmanager/initd  /etc/init.d/htpcmanager

    #Changing APP_PATH
    sed -i -e 's/APP_PATH\=\/path\/to\/htpc-manager/APP_PATH\=\/opt\/htpcmanager\/Htpc.py/g' /etc/init.d/htpcmanager

    #Changing DAEMON_OPTS
    sed -i -e 's/DAEMON_OPTS\=\" Htpc.py\"/DAEMON_OPTS\=\"\"/g' /etc/init.d/htpcmanager

    #Changing RUN_AS user
    sed -i -e 's/RUN_AS\=root/RUN_AS\=htpcmanager/g' /etc/init.d/htpcmanager

    #Making init.d script executable
    chmod +x /etc/init.d/htpcmanager

    #Enabling init.d script
    update-rc.d htpcmanager defaults

    #Creating default config
    touch /etc/default/htpcmanager

    #Changing ownership of directory
    chown htpcmanager:mediaApps -R /opt/htpcmanager

    printf "##HTPCManager Installed##\n\n"
}

#Install Media Scripts
function InstallMediaScripts {
    printf "Installing Media Scripts\n"

	#Checking if Base package is loaded
    if [[ "$basePackageInstalled" == false ]]; then
    	BaseFunction

    	#Setting BaseInstalled flag to true
    	basePackageInstalled=true
    fi

    printf "##Media Scripts Installed##\n\n"
}

#Post Install Function
function PostInstallFunction {
    #Removing temp directory
    rm -rf /tmp/MSPT

    #Echoing sample NFS data into fstab
    printf "\n\n###Sample NFS Shares###\n" >> /etc/fstab
    echo "#192.168.1.3:/nas/NASDisk-00006/Movies /Library/Movies nfs auto,bg,nfsvers=3,intr,timeo=18 0 0" >> /etc/fstab
    echo "#192.168.1.3:/nas/NASDisk-00005/TV /Library/TV nfs auto,bg,nfsvers=3,intr,timeo=18 0 0" >> /etc/fstab

    #Writing to screen
    printf "It is highly recommended to restart to allow all of the apps to autostart.\n"
    printf "Thanks - tscrip\n\n"
}

####
#End Functions
####

####
#Beginning Checks
####

####
#Doing dependency checks for required applications
printf "### Running some dependency checks ###\n"
####

#Checking for whiptail
if [[ -n $WHIPTAIL_PATH ]]
then
   #Whiptail is installed
   whiptailInstalled=true

else
   #Need to install whiptail 
   whiptailInstalled=false

   printf "Whiptail is not installed. Please install whiptail to run this script.\n\n"
   pause
   exit
fi

#Checking for git
if [[ -n $GIT_PATH ]]
then
   #Git is installed
   gitInstalled=true

else
   #Need to install Git
   gitInstalled=false
   
   printf "Git is not installed. Please install git to run this script.\n\n"
   pause
   exit
fi

#Checking for pip
if [[ -n $PIP_PATH ]]
then
   #pip is installed
   pipInstalled=true

else
   #Need to install pip
   pipInstalled=false
   
   printf "Pip is not installed. Please install pip to run this script.\n\n"
   pause
   exit
fi

#Verifying user is root
if [[ $(whoami) != "root" ]]; then
    #User is not root

    printf "This script need to be run as root. Please use sudo or log in as root to continue.\n\n"
    pause
    exit

fi

####
#End of Checks
####

####
#User Prompt
####
whiptail --title "Select Apps Dialog" --checklist --separate-output \
"Choose what apps you want installed" 15 60 8 \
"SickRage" "" OFF \
"Sickbeard" "" OFF \
"Plex" "" OFF \
"Transmission" "" OFF \
"Headphones" "" OFF \
"CouchPotato" "" OFF \
"Media_Scripts" "" OFF 2>results

while read choice
do

#Looping through user choices
case $choice in
SickRage) InstallSickRage
;;
Sickbeard) InstallSickbeard
;;
Plex) InstallPlex
;;
Transmission) InstallTransmission
;;
Headphones) InstallHeadphones
;;
CouchPotato) InstallCouchPotato
;;
Media_Scripts) InstallMediaScripts
;;
*)
;;
esac
done < results

#Running Post Install Function
PostInstallFunction
