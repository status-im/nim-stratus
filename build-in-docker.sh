#!/bin/sh

sudo add-apt-repository ppa:git-core/ppa
sudo apt-get update
sudo apt-get install -y --fix-missing cmake build-essential git libpcre3-dev libssl-dev git

# the minor Qt version keeps getting updated inside the Docker image
export PKG_CONFIG_PATH="$(echo /opt/qt/*/gcc_64/lib/pkgconfig)"
export LD_LIBRARY_PATH="$(echo /opt/qt/*/gcc_64/lib/)"

make -j2 clean
make -j2 appimage

