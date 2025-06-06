#!/bin/bash

set -ouex pipefail

# this installs a package from fedora repos
dnf5 install -y openfortivpn \
        qdirstat \
        earlyoom

# Downlaod and install Azure data studio
wget https://go.microsoft.com/fwlink/?linkid=2301926 -O /tmp/azure-data-studio.rpm
dnf5 install -y /tmp/azure-data-studio.rpm

# Add dotnet install script
wget https://dot.net/v1/dotnet-install.sh -O /usr/bin/dotnet-install
chmod +x /usr/bin/dotnet-install

# Add nvm installer 
wget https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh -O /usr/bin/nvm-install
chmod +x /usr/bin/nvm-install

# Add teams for Linux
wget https://github.com/IsmaelMartinez/teams-for-linux/releases/download/v2.0.14/teams-for-linux-2.0.14.AppImage -O /usr/bin/teams_for_linux.appimage
chmod +x /usr/bin/teams_for_linux.appimage

# Add openfortivpn-webview
wget https://github.com/gm-vm/openfortivpn-webview/releases/download/v1.2.3-electron/openfortivpn-webview-1.2.3-x86_64.AppImage -O /usr/bin/openfortivpn-webview.appimage
chmod +x /usr/bin/openfortivpn-webview.appimage

# Enable earlyoom
systemctl enable earlyoom.service

<<'###BLOCK-COMMENT'
#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux 

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
###BLOCK-COMMENT