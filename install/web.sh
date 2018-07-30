#!/bin/bash
logfile=build.log

# Get current Directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#inlcude config.sh
. $DIR/config.sh

#Get Parrent Directory
Basefolder="$(cd ../; pwd)" 

echo -ne '###############           (60%)\r'
# WEB SERVICES INSTALLATION
echo 'Installing nodejs...' >> $logfile 2>&1
   if is_pione; then
      echo "Pi-1 Detected" >> $logfile 2>&1
   elif is_pione_w; then
      echo "Pi0w Detected" >> $logfile 2>&1
   elif is_pitwo; then
      echo "Pi-2 Detected" >> $logfile 2>&1
   else
      echo "Pi-3 Detected" >> $logfile 2>&1
   fi

sudo node -v | grep -q v10 > /dev/null
if [ ! $? == 0 ]; then
    echo "Installing Node version 10" >> $logfile 2>&1
    sudo wget -O - https://raw.githubusercontent.com/audstanley/NodeJs-Raspberry-Pi/master/Install-Node.sh | sudo bash; >> $logfile 2>&1
    else
    echo "Node 10 exsist, skipping" >> $logfile 2>&1
fi
echo -ne '################          (65%)\r'
# install pm2 web server
if [ ! -x /usr/bin/pm2 ]; then
    echo "PM2 not found, lets install it.." >> $logfile 2>&1
    sudo npm install pm2@2.9 -g >> $logfile 2>&1
    sudo chmod +x /opt/nodejs/bin/pm2 >> $logfile 2>&1
    sudo ln -sfn /opt/nodejs/bin/pm2 /usr/bin/pm2 >> $logfile 2>&1
    sudo rm -rf ~/.pm2 >> $logfile 2>&1
else
echo "PM2 Exsist, skipping.." >> $logfile 2>&1
fi
echo -ne '##################        (70%)\r'
cd $Basefolder/web
sudo npm install --production >> $logfile 2>&1
echo -ne '###################       (72%)\r'
sudo pm2 start process.json --env production >> $logfile 2>&1
echo -ne '####################      (75%)\r'
sudo pm2 startup >> $logfile 2>&1
sudo pm2 save >> $logfile 2>&1
echo -ne '#####################     (80%)\r'


