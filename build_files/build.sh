#!/bin/bash

set -ouex pipefail

# this installs a package from fedora repos
dnf5 install -y openfortivpn \
        earlyoom \
        libgdiplus

# Downlaod and install Azure data studio
wget https://go.microsoft.com/fwlink/?linkid=2324527 -O /tmp/azure-data-studio.rpm
dnf5 install -y /tmp/azure-data-studio.rpm

# Add teams for Linux
wget \
    https://github.com/IsmaelMartinez/teams-for-linux/releases/download/v2.8.0/teams-for-linux-2.8.0.AppImage \
    -O /usr/bin/teams_for_linux.appimage
chmod +x /usr/bin/teams_for_linux.appimage

# Add OpenSnitch
wget https://github.com/evilsocket/opensnitch/releases/download/v1.8.0/opensnitch-1.8.0-1.x86_64.rpm -O /tmp/open-snitch.rpm
wget https://github.com/evilsocket/opensnitch/releases/download/v1.8.0/opensnitch-ui-1.8.0-1.noarch.rpm -O /tmp/open-snitch-ui.rpm
dnf5 install -y /tmp/open-snitch.rpm /tmp/open-snitch-ui.rpm

# Enable earlyoom
systemctl enable earlyoom.service

# Enable OpenSnitch
systemctl enable opensnitchd.service

<<'###BLOCK-COMMENT'
#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

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