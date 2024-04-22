#!/bin/bash

GH_PSA="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"
BACKGROUND_COLOR="#141414"

# =====================================================================================================================
#   Git
# =====================================================================================================================

# Install GitHub CLI
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) &&
    mkdir -p -m 755 /etc/apt/keyrings &&
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
    sudo apt update &&
    sudo apt install gh -y

# Authenticate into Github
echo "$GH_PSA" | gh auth login --git-protocol ssh --hostname GitHub.com --with-token

# Generate SSH key
ssh-keygen -q -t ed25519 -C "brunosag02@gmail.com" -f ~/.ssh/id_ed25519 -N "" <<<y
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Remove existing "ubuntu" keys from GitHub
existing_keys=($(gh ssh-key list | grep "ubuntu" | awk '{print $5}'))
for key in "${existing_keys[@]}"; do
    gh ssh-key delete "$key" -y
done

# Add newly generated key to GitHub
gh ssh-key add ~/.ssh/id_ed25519.pub --title "ubuntu"

# =====================================================================================================================
#   Extensions
# =====================================================================================================================

# Install GNOME Extensions CLI
sudo apt install pipx
pipx install gnome-extensions-cli --system-site-packages
echo 'export PATH="~/.local/bin:$PATH"' >>~/.bashrc
export PATH="~/.local/bin:$PATH"

# Install extensions
gnome-extensions-cli install AlphabeticalAppGrid@stuarthayhurst hidetopbar@mathieu.bidon.ca user-theme@gnome-shell-extensions.gcampax.github.com
gnome-extensions-cli install hidetopbar@mathieu.bidon.ca
gnome-extensions-cli install user-theme@gnome-shell-extensions.gcampax.github.com

# =====================================================================================================================
#   Theme
# =====================================================================================================================

# Install Orchis theme
sudo apt install gnome-themes-extra gtk2-engines-murrine sassc
git clone git@github.com:vinceliuice/Orchis-theme.git
cd Orchis-theme
./install.sh -t grey -c dark -l -u
cd ..
rm -r -f Orchis-theme

# Install Tela icons
git clone git@github.com:vinceliuice/Tela-icon-theme.git
cd Tela-icon-theme
./install.sh -c blue
cd ..
rm -r -f Tela-icon-theme

# Set GTK theme
dconf write /org/gnome/desktop/interface/gtk-theme "'Orchis-Grey-Dark'"

# Set Shell theme
dconf write /org/gnome/shell/extensions/user-theme/name "'Orchis-Grey-Dark'"

# Set Icon theme
dconf write /org/gnome/desktop/interface/icon-theme "'Tela-blue-dark'"

# Set background
dconf write /org/gnome/desktop/background/picture-uri '""'
dconf write /org/gnome/desktop/background/picture-uri-dark '""'
dconf write /org/gnome/desktop/background/primary-color "'""$BACKGROUND_COLOR""'"

# Install GNOME Tweaks
sudo apt install gnome-tweaks

# =====================================================================================================================
#   Software
# =====================================================================================================================

# Install Flatpak
sudo apt install flatpak
sudo apt install gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

# Install VSCode
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" -y
sudo apt update
sudo apt install code

# Install Spotify
curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list
sudo apt update && sudo apt install spotify-client

# Install Extension Manager
flatpak install flathub com.mattjakeman.ExtensionManager

# Install Dconf Editor
flatpak install flathub ca.desrt.dconf-editor

# Install WhatsApp
flatpak install flathub io.github.mimbrero.WhatsAppDesktop

# Install Discord
flatpak install flathub com.discordapp.Discord

# Install Stremio
flatpak install flathub com.stremio.Stremio

# Install Inkscape
flatpak install --user flathub org.inkscape.Inkscape
