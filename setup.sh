#!/bin/zsh

color_desc="\033[36m\u27F3 "
color_cmd="\033[30;1m"
reset="\033[0m"

success="\033[32m\u2713 "
fail="\033[31m\u2717 "

function describe_step {
  desc_txt="$1"
  shift
  cmd=$@

  echo -e "${color_desc}${desc_txt}${reset}"
  output=$(eval $cmd 2>&1)
  exit_code=$?
  # TODO figure out how to tee + get original exit code + save output in a variable
  echo $output >> $HOME/.dotfiles/setup.log

  # back one line and clear it
  echo -e "\033[2A" && echo -en "\033[2K"

  if [ $exit_code -eq "0" ]; then
    echo -en "${success}${desc_txt}"
  else
    echo -e "${fail}${desc_txt}${reset}"
    echo -e "${color_cmd}${cmd}${reset}"
    echo $output
    echo
    echo -e "${fail}Aborting, see above output before continuing"
    exit $exit_code
  fi
  echo -e "${reset}"
}

function step {
  describe_step "$*" $@
}

function skip {
  describe_step $1
}

describe_step "Check for .zshrc file" test -f ~/.zshrc

describe_step "Check for .oh-my-zsh folder" test -d ~/.oh-my-zsh

step ln -sf ~/.dotfiles/.bashrc ~/.bashrc

step ln -sf ~/.dotfiles/.gitignore_global ~/.gitignore_global

step ln -sf ~/.dotfiles/r42.zsh-theme ~/.oh-my-zsh/custom/themes/z42.zsh-theme

describe_step "Set zsh theme to r42" sed -i "'s/ZSH_THEME=\([^ ]\+\)$/ZSH_THEME=\"r42\"/'" ~/.zshrc

if [ -x "$(which brew)" ]; then
  skip "Skipping homebrew installation"
else
  step curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
fi

step brew tap homebrew/bundle

step brew bundle --file ~/.dotfiles/Brewfile

step brew uninstall --ignore-dependencies python

### Python ###
step pyenv install --skip-existing 3.7.9
step pyenv global 3.7.9

describe_step "Include .bashrc in .zshrc" "grep -qxF 'source ~/.bashrc' ~/.zshrc || echo 'source ~/.bashrc' >> ~/.zshrc"

echo
echo -e "-> Log available in: $HOME/.dotfiles/setup.log"
