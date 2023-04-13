#!/bin/bash
set -e -o pipefail

# Usage:
# ./install.sh

# Get the latest release version number
if [[ -z "${VERSION}" ]]; then
    VERSION=$(curl -s https://api.github.com/repos/openshift/microshift/releases | grep tag_name | grep -v nightly | head -n 1 | cut -d '"' -f 4)
fi
echo "Install MicroShift version: ${VERSION}"

# Function to get Linux distribution
get_distro() {
    DISTRO=$(grep -E '^(ID)=' /etc/os-release| sed 's/"//g' | cut -f2 -d"=")
    if [[ $DISTRO != @(ubuntu) ]]; then
        echo "This Linux distro is not supported by the install script: ${DISTRO}"
        exit 1
    fi
}

# Function to get system architecture
get_arch() {
    ARCH=$(uname -m | sed "s/x86_64/amd64/" | sed "s/aarch64/arm64/")
    if [[ $ARCH != @(amd64|arm64) ]]; then
        printf "arch %s unsupported" "$ARCH" >&2
        exit 1
    fi
}

# Function to get OS version
get_os_version() {
    OS_VERSION=$(grep -E '^(VERSION_ID)=' /etc/os-release | sed 's/"//g' | cut -f2 -d"=")
}

# Install dependencies
install_dependencies() {
    case $DISTRO in
        "ubuntu")
            sudo apt-get install -y \
                policycoreutils-python-utils \
                conntrack \
                firewalld
            ;;
    esac
