#!/bin/sh

# Works on Ubuntu 14.04

# This script will install all the dependencies for compiling the CC1110 firmware
# THIS WILL ALSO WRITE THE CODE TO THE CHIP, SO DONE RUN IT WHEN CONNECTED TO THE BLE113

sudo apt-get update 
sudo apt-get install -y git make build-essential libboost-all-dev pkg-config libusb-1.0-0-dev sdcc
git clone https://github.com/dashesy/cc-tool.git
cd cc-tool
./configure
sudo make install
cd ../
git clone https://github.com/ps2/rileylink.git
cd rileylink/firmware/cc1110/
mkdir output
make