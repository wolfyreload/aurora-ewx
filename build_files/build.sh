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

# Enable earlyoom
systemctl enable earlyoom.service

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