#!/bin/bash
set -ouex pipefail

if [[ "${IMAGE_VARIANT:-all}" == "server" ]]; then
    echo "Skipping NVIDIA setup for server variant"
    exit 0
fi

# RPM Fusion NVIDIA Installation Reference:
# https://rpmfusion.org/Howto/NVIDIA
# https://docs.fedoraproject.org/en-US/fedora/latest/release-notes/
#   hardware/nvidia/

# Installakmods for building kernel modules from kmod source packages
dnf5 install -y akmods

# Install NVIDIA drivers from RPM Fusion
dnf5 install -y \
    xorg-x11-drv-nvidia \
    xorg-x11-drv-nvidia-libs \
    xorg-x11-drv-nvidia-cuda \
    nvidia-container-toolkit

# Build the kernel module for the running kernel
KERNEL_VERSION=$(rpm -q kernel --queryformat "%{VERSION}-%{RELEASE}.%{ARCH}\n")
akmods --force --kernels "${KERNEL_VERSION}"

# Ensure the NVIDIA kernel module is regenerated on boot
systemctl enable nvidia-sleep.service