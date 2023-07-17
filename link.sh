#!/bin/bash

# link.shのあるディレクトリ
source_dir="$(dirname $(readlink -f "$0"))/"  
# シンボリックリンクを作成するディレクトリ
target_dir=$HOME/  

# 対象のdotfileリスト
dotfiles=(.bashrc .inputrc)

for dotfile in "${dotfiles[@]}"; do

    # dotfilesで定義されたファイル
    source_file="$source_dir$dotfile"
    # target_dirにある対象のファイル
    target_file="$target_dir$dotfile"

    echo checking dotfile : $target_file

    # 対象にファイルが存在している場合
    if [ -e "$target_file" ] ; then

        # シンボリックリンク
        if [ -L "$target_file" ] ; then
            echo symbolic link $target_file already exist
            continue
        fi

        # 置換前のファイル
        if [ -f "$target_file" ] ; then
            echo mv $target_file $target_file.dotfiles.old
            mv $target_file $target_file.dotfiles.old
        fi
    fi

    # link 作成
    echo ln -s $source_file $target_file
    ln -s $source_file $target_file 

done
