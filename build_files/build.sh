#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y libgdiplus

# Docker CE from Docker's official repo (same approach as Aurora DX)
dnf5 -y config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
sed -i "s/enabled=.*/enabled=0/g" /etc/yum.repos.d/docker-ce.repo
dnf5 -y install --enablerepo=docker-ce-stable \
  containerd.io \
  docker-buildx-plugin \
  docker-ce \
  docker-ce-cli \
  docker-compose-plugin \
  docker-model-plugin

systemctl enable docker.socket

# VS Code from Microsoft's official repo (same approach as Aurora DX)
tee /etc/yum.repos.d/vscode.repo <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
sed -i "s/enabled=.*/enabled=0/g" /etc/yum.repos.d/vscode.repo
dnf5 -y install --enablerepo=code code

# Microsoft Intune + Edge
# Official Linux Intune packages target Ubuntu and RHEL, not Fedora. Aurora is
# Fedora 44 / KDE, so we use the RHEL 10 builds (C++ identity broker, GTK4,
# webkitgtk6.0). They still install into /opt/microsoft; on Aurora /opt is a
# symlink to /var/opt, so after the RPM install we relocate that tree into
# /usr/lib/opt and recreate /opt/microsoft at boot via tmpfiles.d.
#
# intune-portal's %post runs authselect and rewrites PAM to an sssd-based
# custom profile. Skip that scriptlet so Aurora's login stack stays intact;
# enable the systemd units and portal symlink ourselves instead.
rpm --import https://packages.microsoft.com/keys/microsoft.asc
rpm --import https://packages.microsoft.com/rhel/10/prod/repodata/repomd.xml.key

tee /etc/yum.repos.d/microsoft-rhel10-prod.repo <<'EOF'
[microsoft-rhel10-prod]
name=Microsoft prod - RHEL 10
baseurl=https://packages.microsoft.com/rhel/10/prod
enabled=0
gpgcheck=1
gpgkey=https://packages.microsoft.com/rhel/10/prod/repodata/repomd.xml.key
EOF

tee /etc/yum.repos.d/microsoft-edge.repo <<'EOF'
[microsoft-edge]
name=Microsoft Edge
baseurl=https://packages.microsoft.com/yumrepos/edge
enabled=0
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# gnome-keyring is required by intune-portal. xdg-desktop-portal-gtk is the
# Secret portal backend on KDE; KWallet does not implement it, which otherwise
# fails Intune login with Misconfiguration(0) / [4kv4v].
dnf5 -y install gnome-keyring xdg-desktop-portal-gtk

# /opt -> /var/opt on this image; /var/opt only exists on a running system.
mkdir -p /var/opt /usr/lib/opt

dnf5 -y install --enablerepo=microsoft-rhel10-prod microsoft-identity-broker
dnf5 -y install --enablerepo=microsoft-rhel10-prod --setopt=tsflags=noscripts intune-portal
dnf5 -y install --enablerepo=microsoft-edge microsoft-edge-stable

# Keep /opt free for other software: store the RPMs under /usr and symlink back.
if [[ -d /var/opt/microsoft ]]; then
    rm -rf /usr/lib/opt/microsoft
    mv /var/opt/microsoft /usr/lib/opt/microsoft
fi
tee /usr/lib/tmpfiles.d/microsoft-opt.conf <<'EOF'
L+ /var/opt/microsoft - - - - /usr/lib/opt/microsoft
EOF

ln -sfn /usr/lib/opt/microsoft/intune/bin/intune-portal /usr/bin/intune-portal

install -d -m 0700 /etc/microsoft/identity-broker/private /etc/microsoft/identity-broker/certs

systemctl enable intune-daemon.socket
systemctl enable intune-daemon.service
systemctl --global enable intune-agent.timer

if [[ -d /usr/share/selinux/packages/intune ]] && command -v checkmodule >/dev/null; then
    (
        cd /usr/share/selinux/packages/intune
        checkmodule -M -m -o intune.mod intune.te
        semodule_package -o intune.pp -m intune.mod
        semodule -i intune.pp
    ) || echo "WARNING: Failed to install Intune SELinux policy module"
fi
