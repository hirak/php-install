.DEFAULT_GOAL := help
version := 7.1.0
tz := "Asia/Tokyo"
PHP_NET_HOST := jp2.php.net
pecl_version := ""
CXXFLAGS := -std=c++11

help: ## このヘルプを表示する
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: setup
setup: ~/.php/ ## スクリプトを色々セットアップ

~/.php/:
	mkdir ~/.php/
	echo export 'PATH=~/.php/current/bin:$PATH' >> ~/.bash_profile
	brew install autoconf re2c bison icu4c openssl curl readline libxml2 libgd libpng libjpeg

.PHONY: current
current: ## 現在のphp version
	@php -v

.PHONY: ls
ls: ## マシンにインストールされているphpの一覧を取得します version不要
	@ls ~/.php/

.PHONY: ls-remote
ls-remote: ## インストールできそうなstable版phpの一覧を表示します version不要
	@php phpversions.php

.PHONY: use
use: ## マシンのデフォルトphpをversionに変更します
	@(cd ~/.php && rm current && ln -s $(version) current)
	@php -v

.PHONY: clean
clean: ## 指定されたバージョンのディレクトリをmake cleanします
	(cd php-$(version) && make clean)

.PHONY: fullclean
fullclean: ## 指定されたバージョンの関連ファイルを完全削除します
	rm -rf php-$(version)
	rm -rf php-$(version).tar.bz2

.PHONY: uninstall
uninstall: ## 指定されたバージョンを~/.phpから削除します
	rm -rf ~/.php/$(version)

.PHONY: download-qa
download-qa: ## download from qa.php.net. need $user & $version
	curl -Lo php-$(version).tar.bz2 "http://downloads.php.net/~$(user)/php-$(version).tar.bz2"

# ~~~~~~~~
php-$(version).tar.bz2:
	curl -Lo php-$(version).tar.bz2 "http://$(PHP_NET_HOST)/get/php-$(version).tar.bz2/from/this/mirror"

php-$(version): php-$(version).tar.bz2
	tar xf php-$(version).tar.bz2

php-$(version)/sapi/cli/php: php-$(version)
	(cd php-$(version) && \
	./configure \
		--prefix=$(HOME)/.php/$(version) \
		--with-config-file-path=$(HOME)/.php/$(version)/etc/ \
		--with-config-file-scan-dir=$(HOME)/.php/$(version)/etc/php/ \
		--disable-cgi \
		--enable-phpdbg \
		--enable-fpm \
		--with-mysqli \
		--enable-pcntl \
		--enable-bcmath \
		--enable-calendar \
		--enable-exif \
		--enable-soap \
		--enable-sockets \
		--with-openssl=$(shell brew --prefix openssl) \
		--with-curl=$(shell brew --prefix curl) \
		--with-readline=$(shell brew --prefix readline) \
		--with-libxml-dir=$(shell brew --prefix libxml2) \
		--with-gd \
		--with-jpeg-dir=$(shell brew --prefix libjpeg) \
		--with-png-dir=$(shell brew --prefix libpng) \
		--with-bz2=$(shell brew --prefix bzip2) \
		--with-zlib=$(shell brew --prefix zlib) \
		--with-iconv=$(shell brew --prefix libiconv) \
		--enable-mbstring \
		--enable-mysqlnd \
		--with-pdo-mysql \
		--enable-re2c-cgoto && \
	make -j2 )

~/.php/$(version): php-$(version)/sapi/cli/php
	(cd php-$(version) && \
		make install && \
		cp php.ini-development ~/.php/$(version)/etc/php.ini && \
		mkdir ~/.php/$(version)/etc/php && \
		echo date.timezone = $(tz) >> ~/.php/$(version)/etc/php/timezone.ini \
		)

.PHONY: pecl-ls
pecl-ls: ## currentバージョンに追加インストールされているpeclライブラリの一覧を出力します
	@ls `~/.php/current/bin/php-config --extension-dir`

.PHONY: pecl
pecl: ~/.php/current/etc/php/$(pecl).ini ## peclライブラリをcurrentバージョンに対してインストールします。 make pecl pecl=memcached など。xdebugだけはmake xdebugでインストールしてください

.PHONY: pecl-build
pecl-build: ## peclライブラリをpeclコマンドではなくphpize & makeでインストールします。コンパイルオプションを手動で指定できます。 make pecl-build pecl=memcached options="--enable-memcached-igbinary"
	~/.php/current/bin/pecl download $(pecl)$(pecl-version)
	tar xf $(pecl)*.tgz
	( cd $(pecl)* && \
		~/.php/current/bin/phpize && \
		./configure --with-php-config=${HOME}/.php/current/bin/php-config $(options) && \
		make && make install && \
		echo extension=$(pecl).so > ~/.php/current/etc/php/$(pecl).ini && \
		cd .. && \
		rm -rf $(pecl)* package.xml; \
	)

.PHONY: pecl-uninstall
pecl-uninstall: ## インストール済みのpeclライブラリを削除します
	~/.php/current/bin/pecl uninstall $(pecl)
	rm -f ~/.php/current/etc/php/$(pecl).ini

~/.php/current/etc/php/$(pecl).ini:
	~/.php/current/bin/pecl install $(pecl)$(pecl-version)
	@echo extension=$(pecl).so > ~/.php/current/etc/php/$(pecl).ini

.PHONY: xdebug
xdebug: ~/.php/current/etc/php/xdebug.ini ## xdebugをcurrentバージョンに対してインストールします。 make xdebug だけでよいです

~/.php/current/etc/php/xdebug.ini:
	~/.php/current/bin/pecl install xdebug
	echo "zend_extension="`~/.php/current/bin/php-config --extension-dir`/xdebug.so > ~/.php/current/etc/php/xdebug.ini

.PHONY: install
install: ~/.php/$(version)

.PHONY: reinstall
reinstall: uninstall clean install
