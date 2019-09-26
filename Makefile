# Copyright (c) 2019 Status Research & Development GmbH. Licensed under
# either of:
# - Apache License, version 2.0
# - MIT license
# at your option. This file may not be copied, modified, or distributed except
# according to those terms.

SHELL := bash # the shell used internally by "make"

.DEFAULT_GOAL := all

# used inside the included makefiles
BUILD_SYSTEM_DIR := vendor/nimbus-build-system

# we don't want an error here, so we can handle things later, in the build-system-checks target
-include $(BUILD_SYSTEM_DIR)/makefiles/variables.mk
-include $(BUILD_SYSTEM_DIR)/makefiles/targets.mk

.PHONY: build-system-checks deps update

GIT_SUBMODULE_UPDATE := git submodule update --init --recursive
build-system-checks:
	@[[ -e "$(BUILD_SYSTEM_DIR)/makefiles" ]] || { \
		echo -e "'$(BUILD_SYSTEM_DIR)/makefiles' not found. Running '$(GIT_SUBMODULE_UPDATE)'.\n"; \
		$(GIT_SUBMODULE_UPDATE); \
		echo -e "\nYou can now run '$(MAKE)' again."; \
		exit 1; \
		}

deps: | deps-common

update: | update-common

DEPLOYQT := linuxdeployqt-continuous-x86_64.AppImage

$(DEPLOYQT):
	wget https://github.com/probonopd/linuxdeployqt/releases/download/continuous/$(DEPLOYQT)
	chmod +x $(DEPLOYQT)

DOTHERSIDE := vendor/DOtherSide/build/lib/libDOtherSideStatic.a

$(DOTHERSIDE):
	echo -e $(BUILD_MSG) "DOtherSide"
	+ cd vendor/DOtherSide && \
		mkdir -p build && \
		cd build && \
		cmake -DCMAKE_BUILD_TYPE=Release .. $(HANDLE_OUTPUT) && \
		$(MAKE) DOtherSideStatic $(HANDLE_OUTPUT)

stratus: $(DOTHERSIDE) stratus.nim | deps
	echo -e $(BUILD_MSG) "$@" && \
		$(ENV_SCRIPT) nim c -d:release -L:-Lvendor/DOtherSide/build/lib/ $(NIM_PARAMS) stratus.nim

APPIMAGE := Stratus-x86_64.AppImage

$(APPIMAGE): stratus $(DEPLOYQT) stratus.desktop
	rm -rf tmp/dist
	mkdir -p tmp/dist/usr/bin
	cp stratus tmp/dist/usr/bin
	cp stratus.desktop tmp/dist/stratus.desktop
	cp stratus.svg tmp/dist/stratus.svg
	cp main.qml tmp/dist/usr/bin
	./$(DEPLOYQT) tmp/dist/stratus.desktop -no-translations -no-copy-copyright-files -qmldir=tmp/dist/usr/bin -appimage

.PHONY: all
all: build-system-checks stratus

.PHONY: appimage
appimage: $(APPIMAGE)

.PHONY: clean
clean: | clean-common
	rm -rf $(APPIMAGE) stratus vendor/DOtherSide/build tmp/dist
	- [[ -d vendor/DOtherSide/build ]] && cd vendor/DOtherSide/build && $(MAKE) clean

