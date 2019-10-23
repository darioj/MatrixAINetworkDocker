#!/bin/sh

#Start cron
service cron start

#This section creates your entrust.json file on the fly each time you start the container
#This requires that you mount a persistent volume from your host OS to the container's /matrix/chaindata directory
#You must have a signAccount.json file in your mounted chaindata directory
PASS="$(date +%s | sha256sum | base64 | head -c 4)pO1@"
echo $PASS > /matrix/gman.pass
echo $PASS >> /matrix/gman.pass
cat /matrix/gman.pass | /matrix/gman --datadir /matrix/chaindata aes --aesin /matrix/chaindata/signAccount.json --aesout /matrix/entrust.json

#This is used to detect first time run. It moves a file and intializes the genisis block
if [ -f "/matrix/man.json" ]; then
  mv /matrix/man.json /matrix/chaindata/
  cd /matrix/ && ./gman --datadir /matrix/chaindata init /matrix/MANGenesis.json
fi

#Move picstore directory into chaindata on first run if it doesn't exist
if [ ! -d "/matrix/chaindata/picstore" ]; then
	mv /matrix/picstore /matrix/chaindata/
fi

#This sets the wallet address based on the mounted persistent volume
MAN_WALLET="$(ls /matrix/chaindata/keystore/)"

#This starts the node using the port and wallet variables
cd /matrix/ && cat /matrix/gman.pass | ./gman --datadir /matrix/chaindata --networkid 1 --debug --verbosity 1 --port $MAN_PORT --manAddress $MAN_WALLET --entrust /matrix/entrust.json --gcmode archive --outputinfo 1 --syncmode full
