#!/bin/bash -e

# uncomment following line to enable benchmark
# DOTFILES_BENCHMARK=0

PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

if [ "$DOTFILES_BENCHMARK" -ge "1" ]; then
  if ! command -v gdate &> /dev/null; then
    # echo "⚠️  DOTFILES_BENCHMARK disabled: gdate not available" >&2
    unset DOTFILES_BENCHMARK
    return
  fi

  # Timing setup - colors and initial checkpoint
  BASHRC_FIRST_CHECKPOINT=$(gdate +%s%3N)

  if [ "$DOTFILES_BENCHMARK" -ge "2" ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color
  fi
fi

# Function to log checkpoint with elapsed time
checkpoint() {
  if [ "$DOTFILES_BENCHMARK" -lt "2" ]; then
    return
  fi
  local current_time=$(gdate +%s%3N)
  local time_unit="ms"
  
  local section_name="$1"
  
  if [ -n "$BASHRC_LAST_CHECKPOINT" ]; then
    local elapsed=$((current_time - BASHRC_LAST_CHECKPOINT))
    
    # Choose color based on elapsed time
    local color
    if [ $elapsed -lt 10 ]; then
      color="$GREEN"
    elif [ $elapsed -lt 50 ]; then
      color="$YELLOW"
    else
      color="$RED"
    fi
    
    echo -e "${color}⏱️  ${section_name}: ${elapsed}${time_unit}${NC}" >&2
  else
    echo -e "${CYAN}🚀 Starting .bashrc timing: ${section_name}${NC}" >&2
  fi
  
  BASHRC_LAST_CHECKPOINT=$current_time
}

checkpoint "Initialization"

export DOTFILES_DIR=$(dirname $(readlink -n ~/.bashrc))

checkpoint "Dotfiles dir setup"

if [ -d "$DOTFILES_DIR/init.d/" ]; then
  for F in $DOTFILES_DIR/init.d/*; do
    if [ -r "$F" ]; then
      source $F
    fi
  done
fi

checkpoint "Init.d scripts sourced"

# lein
export LEIN_SUPPRESS_USER_LEVEL_REPO_WARNINGS=true
export LEIN_JVM_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

checkpoint "Lein configuration"

# dotfiles
function dotfiles_save() {
  (
    cd $DOTFILES_DIR &&
    (git diff --stat | cat) &&
    git add -A . &&
    git commit -am"saving dotfiles as of $(date +"%b %d, %Y")" &&
    git push origin
  )
}

function dotfiles_load() {
  source $DOTFILES_DIR/.bashrc
}

function dotfiles_pull() {
  (
    cd $DOTFILES_DIR &&
    git stash -u &&
    git pull --rebase origin main &&
    git stash pop
  )
}

checkpoint "Dotfiles functions"

# git
function bootstrap_git() {
  git config --global pull.rebase true
  git config --global alias.co checkout
  git config --global alias.st status
  git config --global alias.pup '!git push --set-upstream origin `git rev-parse --abbrev-ref HEAD`'
  git config --global alias.cleanup '!git fetch --prune && git branch -d $(git branch --merged | tail +2)'

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

alias gdiff='git diff --no-index -- '

checkpoint "Git configuration"

# z
[ -f "/opt/homebrew/etc/profile.d/z.sh" ] && . /opt/homebrew/etc/profile.d/z.sh

checkpoint "z setup"

#shell
export PATH=$HOME/bin:/usr/local/bin:$PATH

export LC_ALL=en_US.UTF-8

export HISTFILESIZE=1000000000
export HISTSIZE=1000000000

setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY

# so that git commit sign works on osx
export GPG_TTY=$TTY

checkpoint "Shell configuration"

# fzf
if command -v fzf &> /dev/null; then
  eval "$(fzf --zsh)"
fi

checkpoint "FZF setup"

#aliases
alias less="less -N"
alias ls='ls -l -G --color'
alias getp='ps axu | grep -v grep | grep -i '
alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test100.zip'
alias ip='ifconfig | grep -e '\''inet [0-9]'\'' | grep -ve '\''inet 127'\'' | awk -F '\'' '\'' '\''{print $2; }'\'' | tr -d '\''\n'\'''
alias fastping='prettyping --nounicode -i 0.1'
alias vdj=vd --filetype json
alias files="fd -t f | xargs bat"

plug () {
  local keyboard="1c-57-dc-8b-99-cb"
  local trackpad="8c-85-90-f2-e1-ac"
  local devices=("$keyboard" "$trackpad")
  
  for address in "${devices[@]}"; do
    if [[ "$address" == *"cb" ]]; then
      local device_name="⌨️ Keyboard"
    else
      local device_name="⬜️ Trackpad"
    fi
    
    echo "--------------------------------"
    echo "Processing $device_name ($address)"
    
    echo "🔌 Unpairing $device_name ($address)..."
    blueutil --unpair "$address" 2>/dev/null || true
    
    echo "🔍 Searching for $device_name ($address)..."
    if blueutil --inquiry 5 | grep -q "$address"; then
      echo "🟢 Found $device_name ($address), attempting to connect..."
      if ! blueutil --connect "$address"; then
        echo "🔴 Error connecting to $device_name ($address)"
      fi
    else
      echo "⏳ $device_name ($address) not found in first (5s) inquiry, trying extended (20s) search..."
      sleep 1
      if blueutil --inquiry 20 | grep -q "$address"; then
        echo "✅ Found $device_name ($address) in extended search, attempting to connect..."
        if ! blueutil --connect "$address"; then
          echo "🔴 Error connecting to $device_name ($address)"
        fi
      else
        echo "🔴 $device_name ($address) not found in either (5s) or (20s) inquiry"
      fi
    fi
  done
}

unplug () {
  local keyboard="1c-57-dc-8b-99-cb"
  local trackpad="8c-85-90-f2-e1-ac"
  local devices=("$keyboard" "$trackpad")
  
  for address in "${devices[@]}"; do
    if [[ "$address" == *"cb" ]]; then
      local device_name="⌨️ Keyboard"
    else
      local device_name="⬜️ Trackpad"
    fi
    
    echo "--------------------------------"
    echo "⚙️ Processing $device_name ($address)"
    
    echo "🔌 Unpairing $device_name ($address)..."
    if blueutil --unpair "$address" 2>/dev/null; then
      echo "🟢 Successfully unpaired $device_name ($address)"
    else
      echo "🔵 Warning: unpairing $device_name ($address) or device was not paired"
    fi
  done
}

checkpoint "plug/unplug defined"

# Final timing summary
if [ "$DOTFILES_BENCHMARK" -ge "1" ]; then
  final_time=$(gdate +%s%3N)
  total_elapsed=$((final_time - BASHRC_FIRST_CHECKPOINT))
  echo -e "🏁 Total .bashrc load time: ${total_elapsed}ms${NC}" >&2

  # Clean up timing variables
  unset BASHRC_FIRST_CHECKPOINT BASHRC_LAST_CHECKPOINT RED GREEN YELLOW BLUE PURPLE CYAN NC checkpoint final_time total_elapsed
fi
