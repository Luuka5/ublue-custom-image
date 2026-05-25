#!/bin/bash
set -ouex pipefail

dnf5 install -y openssh-server

#mkdir -p /etc/systemd/system/multi-user.target.wants
#ln -sf /usr/lib/systemd/system/sshd.service /etc/systemd/system/multi-user.target.wants/sshd.service
