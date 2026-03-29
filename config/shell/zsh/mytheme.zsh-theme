# link zsh-theme file

# if [ ! -L ~/.oh-my-zsh/themes/mytheme.zsh-theme ]; then
#     echo "ln -s $(pwd)/mytheme.zsh-theme ~/.oh-my-zsh/themes/mytheme.zsh-theme"
#     ln -s $(pwd)/mytheme.zsh-theme ~/.oh-my-zsh/themes/mytheme.zsh-theme
# fi

# special variables

current_username='%n'
hostname='%m'
current_date='%D'
current_time='%t'
# current_time='%*' # hh:mm:ss
current_directory='%3~'

last_command_status='$?'
bg_job_number='%!' # the PID of the most recently executed background process
prompt_level='%#' # '%' : normal user '#': super user
shell_options='$-'

history_num='%h'
# history_num='%!'
terminal_name='%y'
terminal_name=`tty`
# ___="" # >


# custom prompt
PROMPT=\
"\

$last_command_status
╔ %F{207}$SHELL 👤%F{039}$current_username${reset_color}@%F{111}🖥 %M${reset_color}:%F{226}📁$current_directory${reset_color} %F{244}[$terminal_name] $history_num${reset_color}
║ $prompt_level $ %F{046}\
"
RPROMPT="📅$current_date 🕐$current_time"

# https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
colorlist() {
	for color in {000..015}; do
		print -nP "%F{$color}$color %f"
	done
	printf "\n"
	for color in {016..255}; do
		print -nP "%F{$color}$color %f"
		if [ $(($((color-16))%6)) -eq 5 ]; then
			printf "\n"
		fi
	done
}

