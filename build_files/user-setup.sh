#!/bin/bash
set -ouex pipefail

USER_ID=1001
HOME_DIR="/home/${USER_NAME}"

useradd -u ${USER_ID} -m -d ${HOME_DIR} -s /usr/bin/fish ${USER_NAME}

usermod -aG wheel,podman,input,video ${USER_NAME}

if [[ -n "${USER_PASSWORD_HASH:-}" ]]; then
    echo "${USER_NAME}:${USER_PASSWORD_HASH}" | chpasswd -e
fi

mkdir -p ${HOME_DIR}/.ssh
chmod 700 ${HOME_DIR}/.ssh

if [[ -n "${USER_SSH_KEY:-}" ]]; then
    echo "${USER_SSH_KEY}" > ${HOME_DIR}/.ssh/authorized_keys
else
    echo "WARNING: USER_SSH_KEY not set, SSH access will not be configured"
fi
chmod 600 ${HOME_DIR}/.ssh/authorized_keys
chown -R ${USER_NAME}:${USER_NAME} ${HOME_DIR}/.ssh

tee /etc/sudoers.d/${USER_NAME}-sudo > /dev/null << 'EOF'
%wheel ALL=(ALL) ALL
EOF
chmod 440 /etc/sudoers.d/${USER_NAME}-sudo

ROOT_HOME="/root"
mkdir -p ${ROOT_HOME}/.ssh
chmod 700 ${ROOT_HOME}/.ssh

if [[ -n "${USER_SSH_KEY:-}" ]]; then
    echo "${USER_SSH_KEY}" > ${ROOT_HOME}/.ssh/authorized_keys
else
    echo "WARNING: USER_SSH_KEY not set, root SSH access will not be configured"
fi
chmod 600 ${ROOT_HOME}/.ssh/authorized_keys
chown -R root:root ${ROOT_HOME}/.ssh

sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

subuid_entries=$(grep "^${USER_NAME}:" /etc/subuid 2>/dev/null || true)
if [[ -z "$subuid_entries" ]]; then
    echo "${USER_NAME}:100000:65536" >> /etc/subuid
fi

subgid_entries=$(grep "^${USER_NAME}:" /etc/subgid 2>/dev/null || true)
if [[ -z "$subgid_entries" ]]; then
    echo "${USER_NAME}:100000:65536" >> /etc/subgid
fi

mkdir -p ${HOME_DIR}/.config/fish

cat > ${HOME_DIR}/.config/fish/config.fish << 'EOF'
if command -v zoxide > /dev/null 2>&1
    zoxide init fish | source
end

function ll
    ls -l
end

function la
    ls -a
end

function lla
    ls -l -a
end

set -gx EDITOR vim
EOF

chown -R ${USER_NAME}:${USER_NAME} ${HOME_DIR}/.config