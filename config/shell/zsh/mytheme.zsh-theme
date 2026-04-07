# link zsh-theme file

# if [ ! -L ~/.oh-my-zsh/themes/mytheme.zsh-theme ]; then
#     echo "ln -s $(pwd)/mytheme.zsh-theme ~/.oh-my-zsh/themes/mytheme.zsh-theme"
#     ln -s $(pwd)/mytheme.zsh-theme ~/.oh-my-zsh/themes/mytheme.zsh-theme
# fi


# --- zsh プロンプトエスケープ変数 ---
# 参考: https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html

# PROMPT で使用する変数
current_username='%n'           # ログインユーザー名
current_host='%M'               # ホスト名 (FQDN)
current_directory='%3~'         # カレントディレクトリ (末尾3階層、HOME は ~ 表示)
terminal_name='%y'              # 端末名 (例: pts/1)
history_num='%h'                # 現在のコマンド履歴番号
prompt_level='%#'               # 通常ユーザー: '%' / スーパーユーザー: '#'

# RPROMPT で使用する変数
current_date='%D{%Y-%m-%d}'     # 日付 (例: 2026-04-07)
current_time='%t'               # 時刻 12h 形式 (例: 3:00PM) / '%*' で hh:mm:ss

# プロンプトカラー (256色: https://en.wikipedia.org/wiki/ANSI_escape_code#Colors)
color_shell='%F{207}'           # シェル名       (pink)
color_user='%F{039}'            # ユーザー名     (cyan)
color_host='%F{111}'            # ホスト名       (light blue)
color_dir='%F{226}'             # ディレクトリ   (yellow)
color_meta='%F{244}'            # 端末名/履歴番号 (gray)
color_error='%F{196}'           # エラー表示     (red)
color_input='%F{046}'           # 入力テキスト   (green)


# --- oh-my-zsh git プラグインの表示スタイル ---
# $(git_prompt_info) の出力に適用される
ZSH_THEME_GIT_PROMPT_PREFIX=" %F{214}⎇ "  # ブランチ名の前に表示
ZSH_THEME_GIT_PROMPT_SUFFIX="${reset_color}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{196}*"    # 未コミットの変更がある場合に付加
ZSH_THEME_GIT_PROMPT_CLEAN=""


# --- プロンプト定義 ---
# 行1: 前コマンドが失敗した場合のみ終了コードを表示 (%?..expr は %? が非0の時だけ展開)
# 行2: シェル名 / ユーザー@ホスト:ディレクトリ / 端末名 / 履歴番号 / gitブランチ
# 行3: プロンプト記号 ($/#) と入力テキストの色
PROMPT=\
"\

%(?..${color_error}✘ %?${reset_color})
${color_shell}$SHELL 👤${color_user}$current_username${reset_color}@${color_host}🖥 $current_host${reset_color}:${color_dir}📁$current_directory${reset_color} ${color_meta}[$terminal_name] $history_num${reset_color}\$(git_prompt_info)
$prompt_level $ ${color_input}\
"
RPROMPT="📅$current_date 🕐$current_time"


# --- ユーティリティ: 256色パレット一覧表示 ---
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
