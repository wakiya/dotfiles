export LANG=ja_JP.UTF-8
export LESSCHARSET=utf-8

export PATH=$PATH:~/bin

alias git="/Applications/Xcode.app/Contents/Developer/usr/bin/git"
alias tmuxn="tmux new-session \; source-file ~/.tmux/session"

export ORACLE_HOME=~/projects/dotfiles/.emacs.d/oracle/instantclient_10_2
# export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$ORACLE_HOME
export SQLPATH=$ORACLE_HOME/aka/sql
export ORACLE_SID=orcl
export PATH=$PATH:$ORACLE_HOME
export NLS_LANG=Japanese_Japan.AL32UTF8
# export TNS_ADMIN=$ORACLE_HOME/network/admin/tnsnames.ora
