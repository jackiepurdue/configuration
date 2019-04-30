_main() {
  export PATH=~/.local/bin:$PATH  
  _history
  _prompt
  unset _main
}

_prompt() {
  export PS1="\[\e[38;5;58m\]$ \[\e[0m\]"
  export PS2="\[\e[38;5;58m\]> \[\e[0m\]"
  unset _prompt
}

_history() {
  export HISTTIMEFORMAT="%h %d %H:%M:%S "
  export HISTFILESIZE=40000
  export HISTSIZE=10000
  export HISTCONTROL=ignoredups
  export HISTIGNORE="&:ls:[bf]g:exit:history"
  shopt -s histappend
  shopt -s cmdhist
  unset _history
}

l() {
  ls
}
ll() {
  ls -l
}
la() {
  ls -a
}
lla() {
  ls -l -a
}

cl() {
  clear
  ls
}

cll() {
  clear
  ls -l
}

clla() {
  clear
  ls -l -a
}

h() {
  cd $HOME
}

r() {
  cd /
}

d() {
  date "+%F %T"
}

ftr() {
  sed -i 's/[[:space:]]*$//' $1
}

sspace() {
  sed -i 'N;/^\n$/d;P;D' $1
}

cformat() {
  ftr $1
  sspace $1
}

extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)
        tar xvjf $1
	;;
      *.tar.gz)
        tar xvzf $1
	;;
      *.bz2)
        bunzip2 $1
        ;;
      *.rar)
        unrar x $1
        ;;
      *.gz)
        gunzip $1
        ;;
      *.tar)
        tar xvf $1
        ;;
      *.tbz2)
       tar xvjf $1
       ;;
      *.tgz)
        tar xvzf $1
        ;;
      *.zip)
        unzip $1
        ;;
      *.Z)
        uncompress $1
        ;;
      *.7z)
        7z x $1
        ;;
      *)
        echo -e "Error: the extension of the file '$1' is not in the list of" \
	        "compressed file types." 1>&2
        ;;
    esac
  else
    echo "Error: the file '$1' is not valid." 1&2
  fi
}

_main
