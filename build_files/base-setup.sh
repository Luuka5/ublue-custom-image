#!/bin/bash
set -ouex pipefail

dnf5 install -y \
    fish \
    zoxide \
    vim \
    git \
    gh \
    htop \
    fastfetch \
    gcc \
    unzip \
    usbutils \
    pciutils \
    killall \
    podman-compose

systemctl enable podman.socket

cat > /etc/profile.d/zoxide.sh << 'EOF'
# Initialize zoxide for fish
if command -v zoxide > /dev/null 2>&1; then
    eval "$(zoxide init fish)"
fi
EOF

install -Dm644 /dev/stdin /etc/fish/conf.d/zoxide.fish << 'EOF'
# Initialize zoxide for fish
if command -v zoxide > /dev/null 2>&1
    zoxide init fish | source
end
EOF

install -Dm644 /dev/stdin /etc/fish/functions/fish_prompt.fish << 'EOF'
function fish_prompt --description 'Write out the prompt'
    set -l last_status $status
    set -l normal (set_color --reset)
    set -l status_color (set_color brgreen)
    set -l cwd_color (set_color $fish_color_cwd)
    set -l vcs_color (set_color brpurple)
    set -l prompt_status ""

    set -q fish_prompt_pwd_dir_length
    or set -lx fish_prompt_pwd_dir_length 0

    set -l suffix '❯'
    if functions -q fish_is_root_user; and fish_is_root_user
        if set -q fish_color_cwd_root
            set cwd_color (set_color $fish_color_cwd_root)
        end
        set suffix '#'
    end

    if test $last_status -ne 0
        set status_color (set_color $fish_color_error)
        set prompt_status $status_color "[" $last_status "]" $normal
    end

    echo -s (prompt_login) ' ' $cwd_color (prompt_pwd) $vcs_color (fish_vcs_prompt) $normal ' ' $prompt_status
    echo -n -s $status_color $suffix ' ' $normal
end
EOF