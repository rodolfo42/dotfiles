
[ -f "/opt/homebrew/opt/mysql-client/bin/mysql" ] && export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

alias gdiff='git diff --no-index -- '
alias less="less -N"
alias ls='ls -l -G --color'
alias getp='ps axu | grep -v grep | grep -i '
alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test100.zip'
alias ip='ifconfig en0 | grep "inet " | awk '\''{print $2}'\'''
alias fastping='prettyping --nounicode -i 0.1'
alias files="fd -t f | xargs bat"