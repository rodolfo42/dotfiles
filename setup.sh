#!/bin/zsh -o pipefail

color_desc="\033[36m\u27F3 "
color_cmd="\033[30;1m"
reset="\033[0m"

success="\033[32m\u2713 "
fail="\033[31m\u2717 "

PATH=$HOME/bin:/usr/local/bin:$PATH

LOGFILE="$HOME/.dotfiles/setup-$(date +%Y-%m-%d-%H-%M-%S).log"
touch "$LOGFILE"

export PATH

echo "=> $(date)\n" >> $LOGFILE

function describe_step {
  desc_txt="$1"
  shift
  cmd=$@

  echo -e "${color_desc}${desc_txt}${reset}"
  
  # Use a temporary file to capture output and preserve exit code
  temp_output=$(mktemp)
  eval $cmd > "$temp_output" 2>&1
  exit_code=$?
  output=$(cat "$temp_output")
  # Only append to log file, don't display on screen
  cat "$temp_output" >> $LOGFILE
  rm "$temp_output"

  if (( exit_code == 0 )); then
    echo -en "${success}${desc_txt}"
  else
    echo -e "${fail}${desc_txt}${reset}"
    echo -e "${color_cmd}${cmd}${reset}"
    echo "$output"
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

describe_step "Link .bashrc" /bin/ln -sf ~/.dotfiles/.bashrc ~/.bashrc

describe_step "Link .gitignore_global" /bin/ln -sf ~/.dotfiles/.gitignore_global ~/.gitignore_global

describe_step "Link r42.zsh-theme" /bin/ln -sf ~/.dotfiles/r42.zsh-theme ~/.oh-my-zsh/themes/r42.zsh-theme

function set_theme {
  local theme=$1
  sed -i '.bak' s/^ZSH_THEME=".*"$/ZSH_THEME=\"$theme\"/g ~/.zshrc
}
describe_step "Set zsh theme to r42" set_theme "r42"

function bootstrap_git {
  git config --global pull.rebase true
  git config --global alias.co checkout
  git config --global alias.st status

  git config --global push.default simple

  # global gitignore
  git config --global core.excludesfile $DOTFILES_DIR/.gitignore_global

  # turn of advices
  git config --global advice.pushnonfastforward false
  git config --global advice.statushints false
  git config --global advice.commitbeforemerge false
  git config --global advice.resolveconflict false
  git config --global advice.implicitidentity false
  git config --global advice.detachedhead false
}
describe_step "Bootstrap git" bootstrap_git

describe_step "Touch .hushlogin" "touch ~/.hushlogin"

function install_homebrew {
  echo "Installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}
if [ -f "/opt/homebrew/bin/brew" ]; then
  skip "Skipping homebrew installation"
else
  describe_step "Install Homebrew" install_homebrew
fi

function install_brew_bundle {
  brew bundle --file ~/.dotfiles/Brewfile
}
describe_step "Install brew bundle" install_brew_bundle

## utils
function install_prettyping {
  if [ ! -f "$HOME/bin/prettyping" ]; then
    mkdir -p $HOME/bin && cd $HOME/bin && curl -O https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping
    chmod +x $HOME/bin/prettyping
  fi
}
describe_step "Install prettyping" install_prettyping

function include_bashrc {
  grep -qxF 'source ~/.bashrc' ~/.zshrc || echo 'source ~/.bashrc' >> ~/.zshrc
}
describe_step "Source .bashrc in .zshrc" include_bashrc

describe_step "Link .vimrc" ln -sf $DOTFILES_DIR/.vimrc ~/.vimrc

echo
echo -e "-> Log available in: $LOGFILE"
