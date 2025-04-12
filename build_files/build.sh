#!/bin/bash

set -ouex pipefail

# this installs a package from fedora repos
dnf5 install -y openfortivpn \
        qdirstat

# Downlaod and install Azure data studio
wget https://go.microsoft.com/fwlink/?linkid=2301926 -O /tmp/azure-data-studio.rpm
dnf5 install -y /tmp/azure-data-studio.rpm

# Add dotnet install script
wget https://dot.net/v1/dotnet-install.sh -O /usr/bin/dotnet-install
chmod +x /usr/bin/dotnet-install

# Add nvm installer 
wget https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh -O /usr/bin/nvm-install
chmod +x /usr/bin/nvm-install

# Add teams for Linux
wget https://github.com/IsmaelMartinez/teams-for-linux/releases/download/v1.12.8/teams-for-linux-1.12.8.AppImage -O /usr/bin/teams_for_linux.appimage
chmod +x /usr/bin/teams_for_linux.appimage

# Add openfortivpn-webview
wget https://github.com/gm-vm/openfortivpn-webview/releases/download/v1.2.3-electron/openfortivpn-webview-1.2.3-x86_64.AppImage -O /usr/bin/openfortivpn-webview.appimage
chmod +x /usr/bin/openfortivpn-webview.appimage