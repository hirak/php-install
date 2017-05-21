#!/bin/sh

make install version=$version
make use version=$version
make xdebug
make pecl pecl=igbinary
make pecl-build pecl=memcached options="--enable-memcached-igbinary"
