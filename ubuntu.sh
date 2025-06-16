#!/bin/bash

readonly ZINC900='#1b1718'

# dconf
dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
dconf write /org/gnome/desktop/interface/gtk-theme "'Yaru-blue-dark'"
dconf write /org/gnome/desktop/interface/icon-theme "'Yaru-blue'"
dconf write /org/gnome/shell/extensions/ding/show-home false
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed false
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position "'BOTTOM'"
dconf write /org/gnome/desktop/input-sources/xkb-options "['compose:ralt']"
dconf write /org/gnome/shell/extensions/dash-to-dock/show-mounts false
dconf write /org/gnome/shell/extensions/dash-to-dock/show-trash false
dconf write /org/gnome/shell/favorite-apps "@as []"
dconf write /org/gnome/settings-daemon/plugins/power/power-button-action "'suspend'"
dconf write /org/gnome/desktop/peripherals/mouse/accel-profile "'flat'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/home "['<Super>e']"
dconf write /org/gnome/settings-daemon/plugins/media-keys/terminal "['<Super>Return']"
dconf write /org/gnome/settings-daemon/plugins/media-keys/www "['<Super>w']"
dconf write /org/gnome/desktop/wm/keybindings/close "['<Super>q']"
dconf write /org/gnome/TextEditor/spellcheck false
dconf write /org/gnome/TextEditor/restore-session false
dconf write /org/gnome/nautilus/icon-view/default-zoom-level '"small-plus"'

# gsettings
gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false

# initial upgrades
sudo apt update -y
sudo apt upgrade -y

# prime-select
sudo prime-select nvidia

# backlight
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash pcie_aspm=force acpi_backlight=native"/' /etc/default/grub
sudo update-grub

# chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chrome.deb
sudo apt install ./chrome.deb
rm chrome.deb

# gh
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
        && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -
sudo apt update
sudo apt install gh
gh auth login

# git config
echo -e "[user]\n\temail = brunosag02@gmail.com\n\tname = brunosag" >~/.gitconfig

# scripts
sudo apt install ddcutil

# python
sudo apt install python3-full

# jetbrains mono
sudo apt install curl
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"

# uninstalls
sudo apt remove yelp -y
sudo apt remove remmina -y
sudo apt remove thunderbird -y
sudo snap remove thunderbird

# vscode
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
wget https://go.microsoft.com/fwlink/?LinkID=760868 -O code.deb
sudo apt install ./code.deb 
rm code.deb

# spotify
sudo snap install spotify

# discord
wget https://discord.com/api/download?platform=linux -O discord.deb
sudo apt install ./discord.deb
rm discord.deb

# syncthing
sudo mkdir -p /etc/apt/keyrings
sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
sudo apt update
sudo apt install syncthing
mkdir ~/.config/autostart/
sudo cp /usr/share/applications/syncthing-start.desktop ~/.config/autostart

# insomnia
wget "https://updates.insomnia.rest/downloads/ubuntu/latest?&app=com.insomnia.app" -O insomnia.deb
sudo apt install ./insomnia.deb
sudo rm insomnia.deb

# flatpak
sudo apt install flatpak -y
sudo apt install gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# extension manager
flatpak install flathub com.mattjakeman.ExtensionManager -y

# stremio
flatpak install flathub com.stremio.Stremio -y

# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

# steam
wget "https://cdn.fastly.steamstatic.com/client/installer/steam.deb" -O steam.deb
sudo apt install ./steam.deb
rm steam.deb

# anki
sudo apt install libxcb-xinerama0 libxcb-cursor0 libnss3

# proton vpn (1.0.8)
wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
sudo dpkg -i ./protonvpn-stable-release_1.0.8_all.deb && sudo apt update
sudo apt install proton-vpn-gnome-desktop -y
rm protonvpn-stable-release_1.0.8_all.deb

# pulseaudio
sudo apt install pulseaudio pavucontrol -y

# cleanup
sudo snap refresh
sudo flatpak update -y
sudo apt autoremove -y

