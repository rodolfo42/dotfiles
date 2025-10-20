export HOMEBREW_NO_AUTO_UPDATE=1
# [ -f "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"

export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
fpath[1,0]="/opt/homebrew/share/zsh/site-functions";
PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/Users/rodolfo.ferreira/miniforge3/condabin:/Users/rodolfo.ferreira/.nvm/versions/node/v20.19.4/bin:/Users/rodolfo.ferreira/bin:/usr/local/bin:/opt/homebrew/opt/postgresql@15/bin:/opt/homebrew/opt/mysql-client/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/usr/local/go/bin:/Applications/iTerm.app/Contents/Resources/utilities:/Users/rodolfo.ferreira/go/bin"; export PATH;
[ -z "${MANPATH-}" ] || export MANPATH=":${MANPATH#:}";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";