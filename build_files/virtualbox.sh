#!/bin/bash

set -ouex pipefail

# VirtualBox needs out-of-tree kernel modules. Build them here against the
# kernel in this image so they are present on an immutable /usr at boot.
# `uname -r` inside the build container is the host kernel, so query RPMs.

KERNEL="$(rpm -q kernel-core --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}\n' | tail -n1)"
KVER="$(rpm -q kernel-core --queryformat '%{VERSION}\n' | tail -n1)"
KREL="$(rpm -q kernel-core --queryformat '%{RELEASE}\n' | tail -n1)"
KARCH="$(rpm -q kernel-core --queryformat '%{ARCH}\n' | tail -n1)"

echo "Installing VirtualBox and building kmods for kernel ${KERNEL}"

install_kernel_devel() {
    if dnf5 -y install "kernel-devel-${KERNEL}" "kernel-devel-matched-${KERNEL}"; then
        return 0
    fi
    if dnf5 -y install "kernel-devel-${KERNEL}"; then
        return 0
    fi

    local koji="https://kojipkgs.fedoraproject.org/packages/kernel/${KVER}/${KREL}/${KARCH}"
    echo "kernel-devel not in dnf repos; downloading from Koji"
    dnf5 -y install \
        "${koji}/kernel-devel-${KVER}-${KREL}.${KARCH}.rpm" \
        "${koji}/kernel-devel-matched-${KVER}-${KREL}.${KARCH}.rpm" \
        || dnf5 -y install "${koji}/kernel-devel-${KVER}-${KREL}.${KARCH}.rpm"
}

install_kernel_devel

# RPMFusion is present on Aurora images but individual repos may be disabled.
install_virtualbox() {
    dnf5 -y install VirtualBox VirtualBox-server akmod-VirtualBox && return 0
    dnf5 -y install --enablerepo=rpmfusion-free --enablerepo=rpmfusion-free-updates \
        VirtualBox VirtualBox-server akmod-VirtualBox && return 0
    dnf5 -y install --enablerepo=rpmfusion-free --enablerepo=rpmfusion-free-updates \
        --enablerepo=rpmfusion-free-updates-testing \
        VirtualBox VirtualBox-server akmod-VirtualBox
}

install_virtualbox

akmods --force --kernels "${KERNEL}" --kmod VirtualBox \
    || akmods --force --kernels "${KERNEL}" --akmod VirtualBox

module_built() {
    local name="$1"
    local path
    for path in \
        "/usr/lib/modules/${KERNEL}/extra/VirtualBox/${name}.ko.xz" \
        "/usr/lib/modules/${KERNEL}/extra/VirtualBox/${name}.ko" \
        "/usr/lib/modules/${KERNEL}/extra/${name}.ko.xz" \
        "/usr/lib/modules/${KERNEL}/extra/${name}.ko" \
        "/usr/lib/modules/${KERNEL}/misc/${name}.ko.xz" \
        "/usr/lib/modules/${KERNEL}/misc/${name}.ko"; do
        if [[ -e "${path}" ]] && modinfo "${path}" >/dev/null 2>&1; then
            return 0
        fi
    done
    return 1
}

for mod in vboxdrv vboxnetadp vboxnetflt; do
    if ! module_built "${mod}"; then
        echo "VirtualBox kmod ${mod} failed to build for ${KERNEL}"
        find /var/cache/akmods/VirtualBox/ -name '*.log' -print -exec cat {} \; || true
        exit 1
    fi
done

depmod -a "${KERNEL}"

if [[ -f /usr/lib/virtualbox/VBoxCreateUSBNode.sh ]]; then
    chmod +x /usr/lib/virtualbox/VBoxCreateUSBNode.sh
fi
chmod +x /usr/libexec/ewx-add-vboxusers

if systemctl cat vboxdrv.service >/dev/null 2>&1; then
    systemctl enable vboxdrv.service
fi

systemctl enable ewx-vboxusers.service

rm -rf /var/cache/akmods /var/log/akmods || true
