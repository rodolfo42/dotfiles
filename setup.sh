#!/bin/zsh -o pipefail

color_desc="\033[36m\u27F3 "
color_cmd="\033[30;1m"
reset="\033[0m"

success="\033[32m\u2713 "
fail="\033[31m\u2717 "

profile=$1

echo "\n=== $(date)\n" >> $HOME/.dotfiles/setup.log

function describe_step {
  desc_txt="$1"
  shift
  cmd=$@

  echo -e "${color_desc}${desc_txt}${reset}"
  # output=$(eval $cmd 2>&1)
  eval $cmd 2>&1 | tee -a $HOME/.dotfiles/setup.log
  exit_code=$?
  # TODO figure out how to tee + get original exit code + save output in a variable
  # echo $output >> $HOME/.dotfiles/setup.log

  # back one line and clear it
  # echo -e "\033[2A" && echo -en "\033[2K"

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

function set_theme {
  local theme=$1
  sed -i '.bak' s/^ZSH_THEME=".*"$/ZSH_THEME=\"$theme\"/g ~/.zshrc
}

function install_prettyping {
  if [ ! -f "$HOME/bin/prettyping" ]; then
    mkdir -p $HOME/bin && cd $HOME/bin && curl -O https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping
    chmod +x $HOME/bin/prettyping
  fi
}

function install_aws {
  if (which aws > /dev/null); then
    echo "Skipping AWS CLI installation"
  else
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"
    sudo installer -pkg /tmp/AWSCLIV2.pkg -target /
    rm -rf /tmp/AWSCLIV2.pkg
  fi
}

function install_docopts {
  curl -s -o $HOME/bin/docopts https://github.com/docopt/docopts/releases/download/v0.6.4-with-no-mangle-double-dash/docopts_darwin_amd64
  chmod ugo+x $HOME/bin/docopts
}

describe_step "Check for .zshrc file" test -f ~/.zshrc

describe_step "Check for .oh-my-zsh folder" test -d ~/.oh-my-zsh

describe_step "Link .bashrc" /bin/ln -sf ~/.dotfiles/.bashrc ~/.bashrc

describe_step "Link .gitignore_global" /bin/ln -sf ~/.dotfiles/.gitignore_global ~/.gitignore_global

describe_step "Link r42.zsh-theme" /bin/ln -sf ~/.dotfiles/r42.zsh-theme ~/.oh-my-zsh/themes/r42.zsh-theme

describe_step "Set zsh theme to r42" set_theme "r42"

step touch ~/.hushlogin

## homebrew
if [ -x "$(which brew)" ]; then
  skip "Skipping homebrew installation"
else
  echo "Installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

step brew bundle --file ~/.dotfiles/Brewfile

if [ ! -z "$profile" ]; then
  step brew bundle --file ~/.dotfiles/Brewfile.$profile
fi

## python
[ -f "/opt/homebrew/bin/python3" ] && step brew uninstall --ignore-dependencies python

step pyenv install --skip-existing 3.13.4

step pyenv global 3.13.4

describe_step "Upgrade pip" pyenv exec pip install --upgrade pip

describe_step "Install visidata" "command -v vd || pyenv exec pip install visidata"

## utils
describe_step "Install prettyping" install_prettyping

describe_step "Include .bashrc in .zshrc" "grep -qxF 'source ~/.bashrc' ~/.zshrc || echo 'source ~/.bashrc' >> ~/.zshrc"

echo
echo -e "-> Log available in: $HOME/.dotfiles/setup.log"
