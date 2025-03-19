#!/bin/bash

set -ouex pipefail

# this installs a package from fedora repos
dnf5 install -y openfortivpn \
        qdirstat

# Downlaod and install Azure data studio
wget -o azure-data-studio.rpm https://go.microsoft.com/fwlink/?linkid=2301926
dnf5 install -y ./azure-data-studio.rpm

# Add dotnet install script
wget https://dot.net/v1/dotnet-install.sh -O /usr/bin/dotnet-install.sh
chmod +x /usr/bin/dotnet-install.sh

