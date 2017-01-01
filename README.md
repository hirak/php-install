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

公式ビルドなのでpeclコマンドがインストールされています。が、pecl installしたあとのecho extension=〜を打ち込むのが面倒くさくなってきたので、ターゲット作りました。
先にuseを実行してからお願いします。バージョン指定はできません

```bash
$ make use version=5.6.29
$ make xdebug
```

xdebugは`zend_extension`なので特別コマンドにしてあります。

### peclライブラリ入れたい

pecl installを行う、`pecl`というターゲットを作りました。php.iniへの書き込みもやってくれるので便利。
インストール済みのリストは `pecl-ls` で取得。

```bash
$ make use version=5.6.29
$ make pecl-ls
opcache.so
$ make pecl pecl=igbinary
```

### peclライブラリ消したい

```bash
$ make pecl-uninstall pecl=igbinary
```

### pecl-build

peclライブラリの中には、独自コンパイルオプションを持つものがあるそうです。
pecl installだとそういったオプションはサポートできないので、自前でphpize & makeする`pecl-build`というターゲットも用意しました。

`pecl`ターゲットの代わりにはなりますが、peclコマンド管理外になります。

optionsという環境引数に、`configure`に渡すオプションを指定してください。

```bash
$ make use version=5.6.29
$ make pecl-ls
opcache.so
$ make pecl-build pecl=memcached options="--enable-memcached-igbinary"
```

