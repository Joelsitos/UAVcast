#!/bin/bash

# Get current Directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#inlcude config.sh
. $DIR/config.sh

#Get Parrent Directory
Basefolder="$(cd ../; pwd)" 

# WEB SERVICES INSTALLATION
echo 'Installing nodejs...'
   if is_pione; then
      echo "Pi-1 Detected"
   elif is_pione_w; then
      echo "Pi0w Detected"
   elif is_pitwo; then
      echo "Pi-2 Detected"
   else
      echo "Pi-3 Detected"
   fi

sudo node -v | grep -q v10 > /dev/null
if [ ! $? == 0 ]; then
    echo "Installing Node version 10"
    sudo wget -O - https://raw.githubusercontent.com/audstanley/NodeJs-Raspberry-Pi/master/Install-Node.sh | sudo bash;
    else
    echo "Node 10 exsist, skipping"
fi

# install pm2 web server
if [ ! -x /usr/bin/pm2 ]; then
    echo "PM2 not found, lets install it.."
    sudo npm install pm2@2.9 -g
    sudo chmod +x /opt/nodejs/bin/pm2
    sudo ln -sfn /opt/nodejs/bin/pm2 /usr/bin/pm2
    sudo rm -rf ~/.pm2
else
echo "PM2 Exsist, skipping.."
fi

cd $Basefolder/web
sudo npm install --production
sudo pm2 start process.json --env production
sudo pm2 startup
sudo pm2 save



