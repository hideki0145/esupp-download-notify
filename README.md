# Magicサポートセンター ダウンロードリスト更新状況通知

Magicサポートセンターのダウンロードリスト更新状況を通知するRubyスクリプトです。

## 動作環境

- Ruby
  > [asdf](https://asdf-vm.com/#/core-manage-asdf) を参考にしてインストールしてください。
- Google Chrome Stable
  > [google-chrome-stable_current_amd64.deb](https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb) をダウンロードして `apt` コマンドでインストールしてください。

## 環境構築

1. 動作環境を満たした上で `bin/setup` を実行してください。
2. `config/config.yml` と `config/locales/ja.yml` の内容を環境に合わせて適宜調整してください。

## 開発コマンド一覧

```sh
# スクリプトを手動実行する
bin/run
# RuboCopによる静的解析を実行する
bundle exec rubocop
# Wheneverによるcrontabファイル書込を実行する
bundle exec whenever --update-crontab
# 最新でないgemのリストを表示する
bundle outdated --strict
```

## Copyright

(c) 2023 Hideki Miyamoto
