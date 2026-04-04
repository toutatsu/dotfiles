# link zsh-theme file

# if [ ! -L ~/.oh-my-zsh/themes/mytheme.zsh-theme ]; then
#     echo "ln -s $(pwd)/mytheme.zsh-theme ~/.oh-my-zsh/themes/mytheme.zsh-theme"
#     ln -s $(pwd)/mytheme.zsh-theme ~/.oh-my-zsh/themes/mytheme.zsh-theme
# fi

# special variables

current_username='%n'
current_date='%D{%Y-%m-%d}'  # %D は yy-mm-dd、%D{...} でフォーマット指定
current_time='%t'
# current_time='%*' # hh:mm:ss
current_directory='%3~'

last_command_status='$?'
bg_job_number='%j'  # 現在のバックグラウンドジョブ数 (未使用)
prompt_level='%#'   # 通常ユーザー: '%' / スーパーユーザー: '#'
shell_options='$-'  # 現在有効なシェルオプション文字列 (未使用)

history_num='%h'
# history_num='%!'
terminal_name='%y'  # zsh プロンプトエスケープ (例: pts/1)
# ___="" # >


# カーソル移動用エスケープ文字 ($'...' は二重引用符内で直接使えないため変数化)
_esc=$'\e'
_cr=$'\r'

# git_prompt_info の表示スタイル (oh-my-zsh git プラグインが提供)
ZSH_THEME_GIT_PROMPT_PREFIX=" %F{214}⎇ "  # ブランチ名の前
ZSH_THEME_GIT_PROMPT_SUFFIX="${reset_color}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{196}*"    # 未コミットの変更あり
ZSH_THEME_GIT_PROMPT_CLEAN=""

# custom prompt
PROMPT=\
"\

%(?..%F{196}✘ %?${reset_color})
%F{207}$SHELL 👤%F{039}$current_username${reset_color}@%F{111}🖥 %M${reset_color}:%F{226}📁$current_directory${reset_color} %F{244}[$terminal_name] $history_num${reset_color}\$(git_prompt_info)
$prompt_level $ %F{046}\
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

