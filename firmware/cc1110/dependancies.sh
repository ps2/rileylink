#!/bin/sh

sudo apt-get update
sudo apt-get install -y git make build-essential libboost-all-dev pkg-config libusb-1.0-0-dev sdcc
git clone https://github.com/dashesy/cc-tool.git
cd cc-tool
sudo make install
cd ../
mkdir output
make
