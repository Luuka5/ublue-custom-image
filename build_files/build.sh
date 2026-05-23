#!/bin/bash

set -ouex pipefail

/ctx/base-setup.sh
/ctx/user-setup.sh

VARIANT="${IMAGE_VARIANT:-all}"

if [[ "$VARIANT" == "all" || "$VARIANT" == "server" ]]; then
    /ctx/server-setup.sh
fi

if [[ "$VARIANT" == "all" || "$VARIANT" == "desktop" ]]; then
    /ctx/nvidia-setup.sh
    /ctx/desktop-setup.sh
fi