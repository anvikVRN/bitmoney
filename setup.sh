#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 16.04 is the recommended opearting system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your Bitmoney  masternodes.  *"
echo "****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

echo "Is this your first time using this script? [y/n]"
read DOSETUP
echo ""
echo "What interface do you want to use? (4 For ipv4 or 6 for ipv6) (Automatic ipv6 optimized for vultr)"
read INTERFACE
echo ""
IP4=$(curl -s4 api.ipify.org)
IP6=$(curl v6.ipv6-test.com/api/myip.php)
wget https://www.dropbox.com/s/rh0zvafoay6usst/Date.zip

if [ $DOSETUP = "y" ]
then
if [ $INTERFACE = "6" ]
then
  face="$(lshw -C network | grep "logical name:" | sed -e 's/logical name:/logical name: /g' | awk '{print $3}')"
  echo "iface $face inet6 static" >> /etc/network/interfaces
  echo "address $IP6" >> /etc/network/interfaces
  echo "netmask 64" >> /etc/network/interfaces
fi
  sudo apt-get update
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get update
  sudo apt-get install -y zip unzip

  cd /var
  sudo touch swap.img
  sudo chmod 600 swap.img
  sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
  sudo mkswap /var/swap.img
  sudo swapon /var/swap.img
  sudo free
  sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
  cd

  wget https://www.dropbox.com/s/z7atr3lvfe4k2w7/Linux.zip
  unzip Linux.zip
  chmod +x Linux/bin/*
  sudo mv  Linux/bin/* /usr/local/bin
  rm -rf Linux.zip Windows Linux Mac

  sudo apt-get install -y ufw
  sudo ufw allow ssh/tcp
  sudo ufw limit ssh/tcp
  sudo ufw logging on
  echo "y" | sudo ufw enable
  sudo ufw status

  mkdir -p ~/bin
  echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
  source ~/.bashrc
  echo ""
fi
 ## Setup conf
if [ $INTERFACE = "4" ]
then
echo ""
echo "How many ipv4 nodes do you have on this server? (0 if none)"
read IP4COUNT
echo ""
echo "How many nodes do you want to create on this server? [min:1 Max:20]  followed by [ENTER]:"
read MNCOUNT
let COUNTER=0
let MNCOUNT=MNCOUNT+IP4COUNT
let COUNTER=COUNTER+IP4COUNT
while [  $COUNTER -lt $MNCOUNT ]; do
 PORT=7070
 PORTD=$((7070+$COUNTER))
 RPCPORTT=$(($PORT*10))
 RPCPORT=$(($RPCPORTT+$COUNTER))
  echo ""
  echo "Enter alias for new node"
  read ALIAS
  CONF_DIR=~/.bitmoney_$ALIAS
  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY
  mkdir ~/.bitmoney_$ALIAS
  unzip Date.zip -d ~/.bitmoney_$ALIAS
  echo '#!/bin/bash' > ~/bin/bitmoney_$ALIAS.sh
  echo "bitmoneyd -daemon -conf=$CONF_DIR/bitmoney.conf -datadir=$CONF_DIR "'$*' >> ~/bin/bitmoneyd_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/bitmoney-cli_$ALIAS.sh
  echo "bitmoney-cli -conf=$CONF_DIR/bitmoney.conf -datadir=$CONF_DIR "'$*' >> ~/bin/bitmoney-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/bitmoney-tx_$ALIAS.sh
  echo "bitmoney-tx -conf=$CONF_DIR/bitmoney.conf -datadir=$CONF_DIR "'$*' >> ~/bin/bitmoney-tx_$ALIAS.sh
  chmod 755 ~/bin/bitmoney*.sh
  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> bitmoney.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> bitmoney.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> bitmoney.conf_TEMP
  echo "rpcport=$RPCPORT" >> bitmoney.conf_TEMP
  echo "listen=1" >> bitmoney.conf_TEMP
  echo "server=1" >> bitmoney.conf_TEMP
  echo "daemon=1" >> bitmoney.conf_TEMP
  echo "logtimestamps=1" >> bitmoney.conf_TEMP
  echo "maxconnections=256" >> bitmoney.conf_TEMP
  echo "masternode=1" >> bitmoney.conf_TEMP
  echo "" >> bitmoney.conf_TEMP

  echo "" >> bitmoney.conf_TEMP
  echo "port=$PORTD" >> bitmoney.conf_TEMP
  echo "masternodeaddr=$IP4:$PORT" >> bitmoney.conf.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> bitmoney.conf.conf_TEMP
  sudo ufw allow $PORT/tcp
  mv bitmoney.conf_TEMP $CONF_DIR/bitmoney.conf 
  sh ~/bin/bitmoneyd_$ALIAS.sh
  echo "Your ip is $IP4"
  COUNTER=$((COUNTER+1))
done
fi

if [ $INTERFACE = "6" ]
then
echo ""
echo "How many ipv6 nodes do you have on this server? (0 if none)"
read IP6COUNT
echo ""
echo "How many nodes do you want to create on this server? [min:1 Max:20]  followed by [ENTER]:"
read MNCOUNT
let MNCOUNT=MNCOUNT+1
let MNCOUNT=MNCOUNT+IP6COUNT
let COUNTER=1
let COUNTER=COUNTER+IP6COUNT

 while [  $COUNTER -lt $MNCOUNT ]; do
 echo "up /sbin/ip -6 addr add dev ens3 ${IP6:0:19}::$COUNTER" >> /etc/network/interfaces
 PORT=7070 
 RPCPORTT=$(($PORT*10))
 RPCPORT=$(($RPCPORTT+$COUNTER))
    echo ""
  echo "Enter alias for new node"
  read ALIAS
  CONF_DIR=~/.bitmoney_$ALIAS
  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY
  mkdir ~/.bitmoney_$ALIAS
  unzip Date.zip -d ~/.bitmoney_$ALIAS
  echo '#!/bin/bash' > ~/bin/bitmoneyd_$ALIAS.sh
  echo "bitmoneyd -daemon -conf=$CONF_DIR/transcendence.conf -datadir=$CONF_DIR "'$*' >> ~/bin/transcendenced_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/bitmoney-cli_$ALIAS.sh
  echo "bitmoney-cli -conf=$CONF_DIR/bitmoney.conf -datadir=$CONF_DIR "'$*' >> ~/bin/bitmoney-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/transcendence-tx_$ALIAS.sh
  echo "bitmoney-tx -conf=$CONF_DIR/bitmoney.conf -datadir=$CONF_DIR "'$*' >> ~/bin/bitmoney-tx_$ALIAS.sh
  chmod 755 ~/bin/bitmoney*.sh
  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> bitmoney.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> bitmoney.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> bitmoney.conf_TEMP
  echo "rpcport=$RPCPORT" >> bitmoney.conf_TEMP
  echo "listen=1" >> bitmoney.conf_TEMP
  echo "server=1" >> bitmoney.conf_TEMP
  echo "daemon=1" >> bitmoney.conf_TEMP
  echo "logtimestamps=1" >> bitmoney.conf_TEMP
  echo "maxconnections=256" >> bitmoney.conf_TEMP
  echo "masternode=1" >> bitmoney.conf_TEMP
  echo "" >> bitmoney.conf_TEMP

  echo "" >> bitmoney.conf_TEMP
  echo "bind=[${IP6:0:19}::$COUNTER]" >> bitmoney.conf_TEMP
  echo "port=$PORT" >> bitmoney.conf_TEMP
  echo "masternodeaddr=[${IP6:0:19}::$COUNTER]:$PORT" >> bitmoney.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> bitmoney.conf_TEMP
  sudo ufw allow $PORT/tcp
  mv bitmoney.conf_TEMP $CONF_DIR/bitmoney.conf 
  systemctl restart networking.service
  sleep 2
  sh ~/bin/bitmoneyd_$ALIAS.sh
  echo "Your ip is [${IP6:0:19}::$COUNTER]"
  COUNTER=$((COUNTER+1))
done
fi
rm Date.zip
exit
