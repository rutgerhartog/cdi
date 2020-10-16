#!/bin/sh

# Get mailspring
URL=$(curl https://github.com/Foundry376/Mailspring/releases/latest -L -s | grep -i deb | grep href | awk -F"=" '{print $2}' | awk -F" " '{print $1}' | tr -d \")
wget https://github.com/${URL} -O /container/mailspring.deb

# Install mailspring
dpkg -i /container/mailspring.deb
DEBIAN_FRONTEND=noninteractive apt-get install -f -y
dpkg -i /container/mailspring.deb

# Clean up
rm /container/mailspring.deb
