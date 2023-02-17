#!/bin/bash -e

export DOTFILES_DIR=$(dirname $(readlink -n ~/.bashrc))

for F in $DOTFILES_DIR/init.d/*; do
  if [ -r "$F" ]; then
    source $F
  fi
done

# lein
export LEIN_SUPPRESS_USER_LEVEL_REPO_WARNINGS=true
export LEIN_JVM_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"


# docker
alias enter_container="docker exec -it \$(docker ps -n 1 -q) /bin/sh"
alias clean_dangling_images='docker images -q --filter=dangling=true | xargs docker rmi -f'
alias remove_containers='docker ps -aq | xargs docker rm -f'


# dotfiles
function dotfiles_save() {
  (
    cd $DOTFILES_DIR &&
    (git diff --stat | cat) &&
    git add -A . &&
    git commit -am"saving dotfiles as of $(date +"%d/%m/%Y")" &&
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
    git pull --rebase origin master &&
    git stash pop
  )
}


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


# homebrew
[ -f "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"

[ -f "/opt/homebrew/etc/profile.d/z.sh" ] && . /opt/homebrew/etc/profile.d/z.sh


#shell
export PATH=$HOME/bin:/usr/local/bin:$PATH

export LC_ALL=en_US.UTF-8

export HISTFILESIZE=1000000000
export HISTSIZE=1000000000

setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY

# so that git commit sign works on osx
export GPG_TTY=$TTY


#aliases
alias less="less -N"
alias ls='ls -l -G --color'
alias getp='ps axu | grep -v grep | grep -i '
alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test100.zip'
alias ip='ifconfig | grep -e '\''inet [0-9]'\'' | grep -ve '\''inet 127'\'' | awk -F '\'' '\'' '\''{print $2; }'\'' | tr -d '\''\n'\'''
alias fastping='prettyping --nounicode -i 0.1'
alias vdj=vd --filetype json
alias files="fd -t f | xargs bat"

#python
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

#go
if [ -d "$HOME/go/bin" ]; then
  export PATH=$HOME/go/bin:$PATH
fi

#utils
function timestamp() {
  date -j -f '%Y-%m-%d %H:%M:%S' "$1" +%s
}

function sizes {
	gdu -ad1 $1 | sort -nr | while read size fname
	do
		for unit in k M G T P E Z Y
		do
			if [ $size -lt 1024 ]
			then
				echo -e "${size}${unit}\t${fname}"
				break
			fi
			size=$((size/1024))
		done
	done
}
