[[ $- == *i* ]] && echo loading dotfiles/.bashrc ... || echo 'non-interactive' > /dev/null

echo_color() {
  local color=$1
  shift
  local message="$*"
  case "$color" in
    "black") echo -e "\033[0;30m${message}\033[0m";;
    "red") echo -e "\033[0;31m${message}\033[0m";;
    "green") echo -e "\033[0;32m${message}\033[0m";;
    "yellow") echo -e "\033[0;33m${message}\033[0m";;
    "blue") echo -e "\033[0;34m${message}\033[0m";;
    "magenta") echo -e "\033[0;35m${message}\033[0m";;
    "cyan") echo -e "\033[0;36m${message}\033[0m";;
    "white") echo -e "\033[0;37m${message}\033[0m";;
    *) echo "${message}";;
  esac
}

export PS1="\[$(echo_color magenta \\s) $(echo_color green \\u)@$(echo_color cyan \\H):$(echo_color yellow \\w) [ \D{%Y/%m/%d} \t ]\] command:\# \! UID:\$\n$ "
