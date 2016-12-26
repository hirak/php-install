hirak/php-install
========

俺の俺による俺のためのphpビルド用Makefile

- macOSのみサポートしてます

## なぜ作ったのか

- php-buildの追従速度が物足りない
    - 7.1.0が出たその瞬間にビルドしたい
- jp2.php.netからダウンロードしたい
- ビルドオプション覚えるのはしんどい


いつものファイルダウンロード、./configureオプション、ビルドと言った手順をmakefile化しました。
汎用性は低い、、です。

```bash
$ make help
```

### セットアップ

```bash
$ git clone git://github.com/hirak/php-install.git path/to/your-favorite-dir
$ cd path/to/your-favorite-dir/php-install
```

動くかどうかよくわからないセットアップスクリプトがあります。

```bash
$ make setup
```

- $HOME/.php/ というディレクトリがある
- makeに必要なライブラリがhomebrewでインストールされている

であればOKです

### ローカルに入ってるPHP一覧

```bash
$ make ls
```

### リリースバージョン一覧 (RC含まない)

```bash
$ make ls-remote
```

### ビルドしてインストール

```bash
$ make install version=7.1.0
```

### デフォルトで使うPHPにする

```bash
$ make use version=7.1.0
```

PATHの通った ~/.php/current/bin にシンボリックリンクを張るだけです。

### アンインストール

( ~/.php/から消すだけ )

```bash
$ make uninstall version=7.1.0
```

### キャッシュ含めて全部消す

```bash
$ make fullclean version=7.1.0
```

## ありそうな質問

### extensionは標準で何がインストールされるんですか

Makefile読んで。

### xdebug入れたい

公式ビルドなのでpeclコマンドがインストールされています。peclコマンドで頑張れ。

```bash
$ pecl install xdebug
...
... (最後にzend_extension= ... みたいな長いやつが表示されるので)
$ echo 'zend_extension=...' > ~/.php/current/etc/php/xdebug.ini
```
