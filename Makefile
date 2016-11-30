.DEFAULT_GOAL := help
version := 7.0.12
PHP_NET_HOST := jp2.php.net

help: ## このヘルプを表示する
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo make clean version=7.0.0
	@echo make install version=7.0.0
	@echo make use version=7.0.0

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

.PHONY: download-krakjoe
download-krakjoe: ## download 7.X-RC
	curl -Lo php-$(version).tar.bz2 "http://downloads.php.net/~krakjoe/php-$(version).tar.gz"

.PHONY: download-tyrael
download-tyrael: ## download 5.6RC
	curl -Lo php-$(version).tar.bz2 "http://downloads.php.net/tyrael/php-$(version).tar.gz"

# ~~~~~~~~
php-$(version).tar.bz2:
	curl -Lo php-$(version).tar.bz2 "http://$(PHP_NET_HOST)/get/php-$(version).tar.bz2/from/this/mirror"

php-$(version): php-$(version).tar.bz2
	tar xf php-$(version).tar.bz2

php-$(version)/sapi/cli/php: php-$(version)
	(cd php-$(version) && \
	./configure \
		--prefix=$(HOME)/.php/$(version) \
		--enable-phpdbg \
		--enable-phpdbg-webhelper \
		--enable-pcntl \
		--enable-bcmath \
		--enable-calendar \
		--enable-exif \
		--enable-sockets \
		--enable-intl \
		--with-icu-dir=/usr/local/opt/icu4c \
		--with-openssl=/usr/local/opt/openssl \
		--with-curl=/usr/local/opt/curl \
		--with-readline=/usr/local/opt/readline \
		--with-libxml-dir=/usr/local/opt/libxml2 \
		--with-bz2 \
		--enable-mbstring \
		--enable-mysqlnd \
		--with-pdo-mysql \
		--enable-zip \
		--enable-re2c-cgoto && \
	make -j2 )

~/.php/$(version): php-$(version)/sapi/cli/php
	(cd php-$(version) && make install)

.PHONY: install
install: ~/.php/$(version)
