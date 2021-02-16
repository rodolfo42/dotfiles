#!/bin/zsh -e

desc="\u001b[32m"
cmd="\u001b[36m"
reset="\u001b[0m"

echo -e "${desc}[1] Linking .bashrc"
echo -e "${cmd}ln -sf ~/.dotfiles/.bashrc ~/.bashrc${reset}"
ln -sf ~/.dotfiles/.bashrc ~/.bashrc
echo


echo
echo -e "${desc}[2] Linking .gitignore_global"
echo -e "${cmd}ln -sf ~/.dotfiles/.gitignore_global ~/.gitconfig_global${reset}"
ln -sf ~/.dotfiles/.gitignore_global ~/.gitconfig_global
echo


echo
echo -e "${desc}[3] Linking r42.zsh-theme"
echo -e "${cmd}ln -sf ~/.dotfiles/r42.zsh-theme ~/.oh-my-zsh/custom/themes/z42.zsh-theme${reset}"
ln -sf ~/.dotfiles/r42.zsh-theme ~/.oh-my-zsh/custom/themes/z42.zsh-theme
echo

### Set up ###

# Install homebrew
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

### Python ###
# brew install pyenv
# pyenv install 3.7.9
# pyenv global 3.7.9

### Brew formulas ###
# brew install coreutils httpie
# brew install fd the_silver_searcher z 
# brew install npm clojure leiningen

# brew install --cask stats
# brew install --cask adoptopenjdk14
# brew install --cask docker

### GNU utils ###

# brew install coreutils binutils diffutils ed findutils \
#     gawk gnu-indent gnu-sed gnu-tar gnu-which gnutls grep \
#     gzip watch wget

echo -e "${desc}[4] Set r42.zsh-theme"