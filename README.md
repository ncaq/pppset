# pppset

**p**andoc **p**df **p**age **p**ersonal **p**aranoia **p**rofile **p**reset

## Usage

記事PDFを生成する場合。

```zsh
nix run 'github:ncaq/pppset#markdown2article' -- foo.md
```

Beamerスライドを生成する場合。

```zsh
nix run 'github:ncaq/pppset#markdown2beamer' -- slides.md
```

引数のMarkdownファイルと同じディレクトリに、
拡張子を`.pdf`に置き換えたファイルが出力されます。

## Development

ローカルにcloneしている場合は以下のように呼び出せます。

```zsh
nix run '.#markdown2article' -- foo.md
nix run '.#markdown2beamer' -- slides.md
```
