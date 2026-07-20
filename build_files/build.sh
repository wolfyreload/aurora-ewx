#!/bin/bash

set -ouex pipefail

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