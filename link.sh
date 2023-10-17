#!/bin/bash

# unlink option

link=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --unlink)
      link=false
      shift
      ;;
    *)
      echo "Usage: $0 [--unlink]"
      exit 1
      ;;
  esac
done



# link.shのあるディレクトリ
source_dir="$(pwd)/"
# シンボリックリンクを作成するディレクトリ
target_dir=$HOME/

# 対象のdotfileリスト
dotfiles=(.profile .zshrc .bashrc .inputrc .tmux.conf .vimrc)

for dotfile in "${dotfiles[@]}"; do

    # dotfilesで定義されたファイル
    source_file="$source_dir$dotfile"
    # target_dirにある対象のファイル
    target_file="$target_dir$dotfile"
    
    echo ------------------------------------------------
    echo checking dotfile : $target_file




    if [ $link = 'true' ]; then

        # 対象にファイルが存在している場合
        if [ -e "$target_file" ] ; then

            # シンボリックリンク
            if [ -L "$target_file" ] ; then
                echo symbolic link $target_file already exist
                continue
            fi

            # 置換前のファイル
            if [ -f "$target_file" ] ; then
                echo move $target_file $target_file.dotfiles.old
                mv $target_file $target_file.dotfiles.old
            fi
        fi

        # link 作成
        echo ln -s $source_file $target_file
        ln -s $source_file $target_file 

    else

        # 対象にファイルが存在している場合
        if [ -e "$target_file" ] ; then

            # シンボリックリンク
            if [ -L "$target_file" ] ; then
                echo remove symbolic link $target_file
                rm $target_file
            fi

            # 置換前のファイル
            if [ -f "$target_file" ] ; then
                echo keep $target_file
            fi
        fi

        if [ -e "$target_file.dotfiles.old" ]; then
            echo move $target_file.dotfiles.old to $target_file
            mv $target_file.dotfiles.old $target_file 
        fi

    fi

done
