#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update the system
echo "Updating system..."
pacman -Syu --noconfirm

# Install required packages for AUR helper
echo "Installing required packages..."
pacman -S --needed --noconfirm base-devel git

# Install AUR helper (yay in this case)
echo "Installing yay AUR helper..."
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
else
    echo "yay is already installed"
fi

# Add Chaotic-AUR repository
echo "Adding Chaotic-AUR repository..."
pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key FBA220DFC880C036
echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
pacman -Syyu --noconfirm
pacman -S --noconfirm chaotic-keyring

# Add CachyOS repository
echo "Adding CachyOS repository..."
# Ensure wget is installed
if ! command -v wget &> /dev/null; then
    pacman -S --noconfirm wget
fi

# Download, extract, and run the CachyOS script
wget https://mirror.cachyos.org/cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz && cd cachyos-repo
sudo ./cachyos-repo.sh
cd ..

# Install tools and libraries for CachyOS PKGBUILDS
echo "Installing tools and libraries for CachyOS PKGBUILDS..."
pacman -S --needed --noconfirm git make gcc binutils fakeroot

# Clone and build CachyOS PKGBUILDS
echo "Cloning CachyOS PKGBUILDS repository..."
git clone https://github.com/CachyOS/cachyos-pkgbuilds.git
cd cachyos-pkgbuilds

# Define packages to build from CachyOS PKGBUILDS
CACHYOS_PKGBUILDS=(
	cachyos-gaming-meta
)

# Build and install CachyOS PKGBUILDS
for package in "${CACHYOS_PKGBUILDS[@]}"; do
    echo "Building and installing $package from CachyOS PKGBUILDS..."
    cd "$package"
    makepkg -si --noconfirm
    sudo pacman -U --noconfirm *.pkg.tar.zst
    cd ..
done

cd ..

# Define Pacman and AUR packages to install
PACMAN_PACKAGES=(
	obsidian
	cider
	vesktop-bin
	lazygit
	firefox
	ddcutil
	steam
	flatpak
	wl-clipboard
	gvfs-google
	flatpak
)

AUR_PACKAGES=(
	vdu_controls
)

CHAOTIC_AUR_PACKAGES=(
	obs-studio-stable
	extension-manager

)

# Install Pacman packages
echo "Installing Pacman packages..."
for package in "${PACMAN_PACKAGES[@]}"; do
    pacman -S --noconfirm "$package"
done

# Install Chaotic-AUR packages
echo "Installing Chaotic-AUR packages..."
for package in "${CHAOTIC_AUR_PACKAGES[@]}"; do
    if pacman -Si "$package" &> /dev/null; then
        pacman -S --noconfirm "$package"
    else
        echo "Package $package not found in Chaotic-AUR repository"
    fi
done

# Install AUR packages not in Chaotic-AUR
echo "Installing AUR packages..."
for package in "${AUR_PACKAGES[@]}"; do
    yay -S --noconfirm "$package"
done

echo "Installing ProtonVPN..."
flatpak install flathub com.protonvpn.www

echo "All packages have been installed successfully."


