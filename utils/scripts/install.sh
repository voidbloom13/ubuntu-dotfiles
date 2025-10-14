#!/usr/bin/env bash

# This script goes through installing all of my default programs.

if [[ -d "$HOME/ubuntu-dotfiles" ]] && [[ ! -d "$HOME/dotfiles" ]]; then
  echo "Renaming '$HOME/ubuntu-dotfiles' to '$HOME/dotfiles'..."
  mv $HOME/ubuntu-dotfiles $HOME/dotfiles
else
  echo "Error with folder structure. Please backup current '$HOME/dotfiles' directory and rename, move, or delete it from your home directory."
  exit 1
fi

# Initial update/upgrade and installs initial software
sudo apt update && 
sudo apt upgrade -y && 
sudo apt-get install -y build-essential cifs-utils curl default-jdk gcc gh git kitty maven nala neofetch nodejs npm python3 python3-pip python3-venv ripgrep stow tmux tree unzip zoxide zsh

# Installs latest fzf
rm -rf ~/.fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
cd ~/.fzf && git pull && ./install

# Installs most recent version of nvim and VS Code from Snap
if [ -f /etc/apt/preferences.d/nosnap.pref ]; then
  sudo rm /etc/apt/preferences.d/nosnap.pref
fi
sudo apt update && sudo apt install -y snapd
sudo systemctl enable --now snapd
sudo snap install obsidian --classic
sudo snap install nvim --classic
sudo snap install code --classic
sudo snap install ghostty --classic

# Installs the .NET SDK
sudo apt install ca-certificates libc6 libgcc-s1 libicu74 liblttng-ust1 libssl3 libstdc++6 zlib1g
sudo add-apt-repository ppa:dotnet/backports
sudo apt-get update && 
sudo apt-get install -y dotnet-sdk-9.0

# Installs Google Chrome
mkdir /etc/apt/keyrings
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo tee /etc/apt/keyrings/google.asc > /dev/null
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google.asc] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
sudo apt-get update
sudo apt-get install google-chrome-stable

# Installs Node Version Manager (NVM) and NodeJS LTS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
nvm install --lts
nvm use --lts

# Installs NPM Packages
sudo npm install -g nodemon typescript typescript-language-server @tailwindcss/language-server

# Installs TPM and Catppuccin Theme for Tmux
mkdir -p ~/.config/tmux/plugins/catppuccin
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux

# Final Setup
bash $HOME/dotfiles/utils/scripts/install-fonts.sh
bash $HOME/dotfiles/utils/scripts/stow.sh

read -p "Setup git/github? [Y/n] " git_config
git_config=${git_config:-Y}
case $git_config in
  [yY] )
    read -p "Git Name: " git_name
    read -p "Git Email: " git_email
    git config --global user.name "$git_name" && git config -- global user.email "$git_email"
    gh auth login
    ;;
  * )
    echo -e "\e[1mSkipping git setup.\e[0m\nTo set git and github up, run the following:\ngit config --global user.name <username>\ngit config --global user.email <email>\ngh auth login"
    ;;
esac

# Cleanup
sudo apt update && sudo apt upgrade -y
sudo apt-get clean
sudo apt-get autoclean
sudo apt-get autoremove

# Next Steps
cd && clear && neofetch && echo -e "\n\e[1;36mNext Steps\e[0m"
echo -e "*Complete \e[32mTMUX\e[0m setup by running [tmux] and pressing [<ctrl>+b, i] to install TPM plugins."
echo -e "*Change user shell to \e[31mzsh\e[0m with chsh."
echo -e "*Reboot and enjoy!"
