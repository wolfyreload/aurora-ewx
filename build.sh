#!/bin/bash

set -ouex pipefail

# this installs a package from fedora repos
dnf5 install -y openfortivpn \
        qdirstat \
        libopenssl1_0_0 # for legacy .net core 3.1 applications

# Downlaod and install Azure data studio
wget https://go.microsoft.com/fwlink/?linkid=2301926 -O /tmp/azure-data-studio.rpm
dnf5 install -y /tmp/azure-data-studio.rpm

# Add dotnet install script
wget https://dot.net/v1/dotnet-install.sh -O /usr/bin/dotnet-install
chmod +x /usr/bin/dotnet-install

# Add nvm installer 
wget https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh -O /usr/bin/nvm-install
chmod +x /usr/bin/nvm-install
