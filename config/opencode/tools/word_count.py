import sys

text = sys.argv[1]
lines = text.splitlines()
words = text.split()
chars = len(text)
print(f"行数: {len(lines)}, 単語数: {len(words)}, 文字数: {chars}")
