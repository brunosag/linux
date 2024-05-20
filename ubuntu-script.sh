#!/bin/bash

# Constants
GH_PSA="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"
DESKTOP_BG_COLOR="hsl(220, 10%, 10%)"

# Initial upgrades
sudo apt update -y
sudo apt upgrade -y

# =============================================================================
#   Git
# =============================================================================

# Install GitHub CLI
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) &&
	sudo mkdir -p -m 755 /etc/apt/keyrings &&
	wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
	sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
	sudo apt update &&
	sudo apt install gh -y

# Authenticate into Github with PSA token
echo "$GH_PSA" | gh auth login --git-protocol ssh --hostname GitHub.com --with-token

if [ ! -f ~/.ssh/id_ed25519 ]; then
	# Generate SSH key
	ssh-keygen -q -t ed25519 -C "brunosag02@gmail.com" -f ~/.ssh/id_ed25519 -N "" <<<y
	eval "$(ssh-agent -s)"
	ssh-add ~/.ssh/id_ed25519

	# Remove existing "ubuntu" keys from GitHub
	mapfile -t existing_keys < <(gh ssh-key list | grep "ubuntu" | awk '{print $5}')
	for key in "${existing_keys[@]}"; do
		gh ssh-key delete "$key" -y
	done

	# Add newly generated key to GitHub
	gh ssh-key add ~/.ssh/id_ed25519.pub --title "ubuntu"
fi

# Add GitHub to trusted hosts
ssh-keyscan github.com >>~/.ssh/known_hosts

# Add .gitconfig
echo -e "[user]\n\temail = brunosag02@gmail.com\n\tname = brunosag" >~/.gitconfig

# =============================================================================
#   Extensions
# =============================================================================

# Install GNOME Extensions CLI
sudo apt install pipx -y
pipx install gnome-extensions-cli --system-site-packages
export PATH="$HOME/.local/bin:$PATH"
if ! grep -qxF export PATH="~/.local/bin:$PATH" ~/.bashrc; then
	echo export PATH="$HOME/.local/bin:$PATH" >>~/.bashrc
fi

# Install extensions
gnome-extensions-cli install user-theme@gnome-shell-extensions.gcampax.github.com
gnome-extensions-cli install AlphabeticalAppGrid@stuarthayhurst
gnome-extensions-cli install hidetopbar@mathieu.bidon.ca

# Tweak extensions settings
dconf write /org/gnome/shell/extensions/alphabetical-app-grid/folder-order-position '"start"' # Alphabetical App Grid -> Position of ordered folders = Start
dconf write /org/gnome/shell/extensions/hidetopbar/mouse-sensitive true                       # Hide Top Bar -> Show panel when mouse approaches edge of the screen = True
dconf write /org/gnome/shell/extensions/hidetopbar/enable-intellihide false                   # Hide Top Bar -> Only hide panel when a window takes the spane = False
dconf write /org/gnome/shell/extensions/hidetopbar/enable-active-window false                 # Hide Top Bar -> Only when the active window takes the space = False

# =============================================================================
#   Theme
# =============================================================================

# Install Orchis theme
sudo apt install gnome-themes-extra gtk2-engines-murrine sassc -y
git clone git@github.com:vinceliuice/Orchis-theme.git
cd Orchis-theme || exit
./install.sh -u
./install.sh -t grey -c dark -l
cd ..
rm -r -f Orchis-theme

# Install Tela icons
git clone git@github.com:vinceliuice/Tela-icon-theme.git
cd Tela-icon-theme || exit
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
dconf write /org/gnome/desktop/background/primary-color "'""$DESKTOP_BG_COLOR""'"

# Install GNOME Tweaks
sudo apt install gnome-tweaks -y

# =============================================================================
#   Settings
# =============================================================================

# Desktop Icons
dconf write /org/gnome/shell/extensions/ding/start-corner '"top-left"' # Position of New Icons = Top Left
dconf write /org/gnome/shell/extensions/ding/show-home false           # Show Personal folder = False

# Dock
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed false         # Auto-hide the Dock = True
dconf write /org/gnome/shell/extensions/dash-to-dock/extend-height false      # Panel mode = False
dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size 32    # Icon size = 32
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position '"BOTTOM"' # Position on screen = Bottom
dconf write /org/gnome/shell/extensions/dash-to-dock/show-trash false         # Show Volumes and Devices = False
dconf write /org/gnome/shell/extensions/dash-to-dock/show-mounts false        # Show Trash = False

# Power
dconf write /org/gnome/shell/last-selected-power-profile '"performance"'             # Power Mode = Performance
dconf write /org/gnome/settings-daemon/plugins/power/idle-dim false                  # Dim Screen = False
dconf write /org/gnome/desktop/session/idle-delay 'uint32 0'                         # Screen Blank = Never
dconf write /org/gnome/settings-daemon/plugins/power/power-button-action '"suspend"' # Power Button Behavior = Suspend

# Text Editor
dconf write /org/gnome/TextEditor/spellcheck false      # Check Spelling = False
dconf write /org/gnome/TextEditor/restore-session false # Restore Session = False

# Nautilus
dconf write /org/gtk/gtk4/settings/file-chooser/show-hidden true        # Show Hidden Files = True
dconf write /org/gnome/nautilus/icon-view/default-zoom-level '"medium"' # Icon Size = Medium

# Mouse
dconf write /org/gnome/desktop/peripherals/mouse/speed -0.5 # Pointer Speed = -0.5

# =============================================================================
#   Software
# =============================================================================

# Install Flatpak
sudo apt install flatpak gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb -y
sudo rm google-chrome-stable_current_amd64.deb
xdg-settings set default-web-browser google-chrome.desktop

# Install VSCode
sudo snap install --classic code
wget -qO- https://raw.githubusercontent.com/harry-cpp/code-nautilus/master/install.sh | bash

# Install Spotify
sudo snap install spotify

# Install Extension Manager
sudo flatpak install flathub com.mattjakeman.ExtensionManager -y

# Install Dconf Editor
sudo flatpak install flathub ca.desrt.dconf-editor -y

# Install WhatsApp
sudo flatpak install flathub io.github.mimbrero.WhatsAppDesktop -y

# Install Discord
sudo flatpak install flathub com.discordapp.Discord -y

# Install Stremio
sudo flatpak install flathub com.stremio.Stremio -y

# Install Inkscape
sudo flatpak install flathub org.inkscape.Inkscape -y

# Update Snap packages
sudo snap refresh

# Update Flatpak packages
sudo flatpak update -y

# =============================================================================
#   Uninstalls
# =============================================================================

# Uninstall AisleRiot Solitaire
sudo apt remove aisleriot -y

# Uninstall Help (yelṕ)
sudo apt remove yelp -y

# Uninstall Mahjongg
sudo apt remove gnome-mahjongg -y

# Uninstall Mines
sudo apt remove gnome-mines -y

# Uninstall Remmina
sudo apt remove remmina -y

# Uninstall Sudoku
sudo apt remove gnome-sudoku -y

# Uninstall Thunderbird Mail
sudo apt remove thunderbird -y
sudo snap remove thunderbird

# Remove unused dependencies
sudo apt autoremove -y

# =============================================================================
#   General
# =============================================================================

# Adjust Dock apps and order
dconf write /org/gnome/shell/favorite-apps "['org.gnome.Nautilus.desktop', 'google-chrome.desktop', 'code_code.desktop', 'io.github.mimbrero.WhatsAppDesktop.desktop', 'spotify_spotify.desktop']"

# Fix Nitro 5 brightness problem
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash pcie_aspm=force acpi_backlight=native"/' /etc/default/grub
sudo update-grub

# Intall JetBrains Mono font
sudo apt install curl -y
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"

# Create scripts directory and add to PATH
if [ ! -d ~/scripts ]; then
	mkdir ~/scripts
fi
if ! grep -qxF export PATH="~/scripts:$PATH" ~/.bashrc; then
	echo export PATH="~/scripts:$PATH" >>~/.bashrc
fi

# =============================================================================
#   Programming Environment
# =============================================================================

# C++ (OpenGL)
sudo apt install -y build-essential make libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev libxcb1-dev libxext-dev libxrender-dev libxfixes-dev libxau-dev libxdmcp-dev libxxf86vm-dev

# Python
sudo apt install -y python-is-python3 ffmpeg

# Racket
# wget https://mirror.racket-lang.org/installers/8.12/racket-8.12-x86_64-linux-cs.sh
# sudo sh racket-8.12-x86_64-linux-cs.sh --in-place --dest /usr/racket
# rm racket-8.12-x86_64-linux-cs.sh
# if ! grep -qxF 'export PATH="/usr/racket/bin:$PATH"' ~/.bashrc; then
# 	echo 'export PATH="/usr/racket/bin:$PATH"' >>~/.bashrc
# fi
# raco pkg install --auto racket-langserver
# raco pkg install --auto fmt

# JavaScript
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install node
nvm use node
nvm alias default node
