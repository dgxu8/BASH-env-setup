#!/bin/bash

install_ubuntu() {
	sudo apt update
	sudo apt upgrade
	sudo apt install ca-certificates curl gnupg

	# Needed for gpg installs (like nodejs)
	sudo mkdir -m 0755 -p /etc/apt/keyrings/
}

install_endeavouros() {
	sudo pacman -Syu
	makepkg -si
}

echo "https://github.com/dennisgxu/BASH-env-setup.git"

if [ -f /etc/os-release ]; then
	echo ""
	echo "=== Updating Package Manager ==="
	. /etc/os-release
	if [ "$ID" == "ubuntu" ]; then
		install_ubuntu
	elif [ "$ID" = "endeavouros" ]; then
		install_endeavouros
	else
		echo "Unknown distro $ID"
		exit 1
	fi
else
	echo "Unable to check distro version"
	exit 1
fi


echo ""
echo "=== Installing UV ==="
INSTALLER_NO_MODIFY_PATH=1 curl -LsSf https://astral.sh/uv/install.sh | sh
