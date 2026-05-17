# mkcd: ディレクトリを作成して移動する
# スクリプト化できない（cd を親シェルに反映する必要があるため）
mkcd() {
  if [ $# -eq 0 ]; then
    echo "使い方: mkcd <dir>" >&2
    return 1
  fi
  mkdir -p "$1" && cd "$1"
}
