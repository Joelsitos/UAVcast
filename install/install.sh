#!/bin/bash
logfile=build.log

. config.sh
. spinner.sh

#Include date time for logging
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "$(tput setaf 2)Starting UAVcast Installation.$(tput sgr0)  $dt" | tee  $logfile 2>&1 

start_spinner
echo -ne '#                         (1%)\r'
# Get current Directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#Get Parrent Directory
Basefolder="$(cd ../; pwd)" 

# Create systemctl for easy stop/start/restart
echo -ne '#####                     (25%)\r'
Systemd=$DIR/"systemd"
main="$MAINPID"
if [ ! -d "$Systemd" ] 
then
 mkdir systemd
fi
# Generate UAVcast.service file
FILE=$DIR/"systemd/UAVcast.service"

/bin/cat <<EOM >$FILE
[Unit]
Description=UAVcast Drone Software
Requires=network-online.target
Wants=network-online.target
After=network-online.target
[Service]
WorkingDirectory=/home/pi/UAVcast
Type=forking
GuessMainPID=no
ExecStart=/bin/bash DroneStart.sh start
KillMode=control-group
Restart=on-failure
[Install]
WantedBy=network-online.target
EOM

# Copy generated UAVcast.service file to systemd
chmod 644 $FILE
cp $FILE /lib/systemd/system/

echo -ne '#######                   (30%)\r'
sudo systemctl daemon-reload >> $logfile 2>&1 
# sudo systemctl enable $FILE

# If RPI 3, we need to remap the UART pins
set_dtoverlay_pi_three >> $logfile 2>&1 

echo -ne '#########                 (35%)\r'
# set config for cmdline.txt and config.txt
do_serial >> $logfile 2>&1 

# This will ensure that all configured network devices are up and have an IP address assigned before boot continues.
sudo systemctl enable systemd-networkd-wait-online.service >> $logfile 2>&1 

# Update and Upgrade the Pi, otherwise the build may fail due to inconsistencies
echo -ne '##########                (40%)\r'
sudo apt-get update -y >> $logfile 2>&1 

# Get the required libraries
sudo apt-get install -y --force-yes jq dnsutils inadyn usb-modeswitch modemmanager network-manager openvpn network-manager-openvpn \
                                     dh-autoreconf gstreamer1.0-tools gstreamer1.0-plugins-good gstreamer1.0-plugins-bad >> $logfile 2>&1 
#                                 wvdial build-essential cmake libboost-all-dev libconfig++-dev libreadline-dev

echo -ne '#############             (50%)\r'
#Args Options for installing web interface
args=$1                           
argsToLower=$(echo "$args" | tr '[:upper:]' '[:lower:]')
case $argsToLower in
        "web")
            #Run Web instalation
            sudo $DIR/./web.sh >> $logfile 2>&1
        ;;
        *)
         printf "\n\n NOTE!!!  Installing UAVcast without Web Interface \n\n use web argurment ( ./install.sh web ) to install web UI.\n\n" | tee  $logfile 2>&1 

esac
echo -ne '###############           (60%)\r'
################# COMPILE UAV software ############
#UAVcast dependencies
mkdir -p $Basefolder/packages
cd $Basefolder/packages

echo -ne '#################         (70%)\r'
#Mavproxy
git clone https://github.com/UAVmatrix/cmavnode.git >> $logfile 2>&1 

echo -ne '####################      (80%)\r'
# Create symlink to cmavnode
sudo ln -s $Basefolder/usr/bin/cmavnode /usr/bin/cmavnode >> $logfile 2>&1

echo -ne '##########################(100%)\r'
sleep 1
echo -ne '\n'
stop_spinner $?
sleep 1
# Completed
printf "$(tput setaf 2)\n\n\ntype 'cat build.log' to view the installation output"
printf "$(tput setaf 2)\n\n\nUAVcast Installastion completed. \n Reboot RPI and access UAVcast webinterface \n by opening your browser and type the IP of RPI.\n$(tput sgr0)" | tee  $logfile 2>&1 
