export PATH=$HOME/bin:/usr/local/bin:$PATH

export LC_ALL=en_US.UTF-8

export HISTFILESIZE=1000000000
export HISTSIZE=1000000000

setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY

# so that git commit sign works on osx
export GPG_TTY=$TTY