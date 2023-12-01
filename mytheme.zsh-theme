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
current_directory='%~'

last_command_status='$?'
bg_job_number='%!' # the PID of the most recently executed background process
prompt_level='%#' # '%' : normal user '#': super user
shell_options='$-'

# ___="" # >


# custom prompt
PROMPT=\
"\
$last_command_status

║${fg[magenta]}Zsh $shell_options 👤${fg[white]}${bg[blue]}$current_username${reset_color}@${fg[cyan]}🖥 %M${reset_color}:${fg[yellow]}📁$current_directory${reset_color} [`tty`]
║$prompt_level $ ${fg[yellow]}\
"
RPROMPT="📅$current_date 🕐$current_time"
