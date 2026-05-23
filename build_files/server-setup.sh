#!/bin/bash
set -ouex pipefail

dnf5 install -y openssh-server

systemctl enable sshd.service