#!/bin/sh

sudo apt-get update
sudo apt-get install -y --fix-missing cmake build-essential git libpcre3-dev libssl-dev

# the minor Qt version keeps getting updated inside the Docker image
export PKG_CONFIG_PATH="$(echo /opt/qt/*/gcc_64/lib/pkgconfig)"
export LD_LIBRARY_PATH="$(echo /opt/qt/*/gcc_64/lib/)"

[ -e vendor/nimbus-build-system/makefiles ] || make V=1
make clean
make -j2 appimage

