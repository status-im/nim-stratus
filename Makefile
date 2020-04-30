# Copyright (c) 2019-2020 Status Research & Development GmbH. Licensed under
# either of:
# - Apache License, version 2.0
# - MIT license
# at your option. This file may not be copied, modified, or distributed except
# according to those terms.

SHELL := bash # the shell used internally by Make

# used inside the included makefiles
BUILD_SYSTEM_DIR := vendor/nimbus-build-system

# we don't want an error here, so we can handle things later, in the ".DEFAULT" target
-include $(BUILD_SYSTEM_DIR)/makefiles/variables.mk

.PHONY: \
	all \
	appimage \
	clean \
	deps \
	update

ifeq ($(NIM_PARAMS),)
# "variables.mk" was not included, so we update the submodules.
GIT_SUBMODULE_UPDATE := git submodule update --init --recursive
.DEFAULT:
	+@ echo -e "Git submodules not found. Running '$(GIT_SUBMODULE_UPDATE)'.\n"; \
		$(GIT_SUBMODULE_UPDATE); \
		echo
# Now that the included *.mk files appeared, and are newer than this file, Make will restart itself:
# https://www.gnu.org/software/make/manual/make.html#Remaking-Makefiles
#
# After restarting, it will execute its original goal, so we don't have to start a child Make here
# with "$(MAKE) $(MAKECMDGOALS)". Isn't hidden control flow great?

else # "variables.mk" was included. Business as usual until the end of this file.

all: stratus

# must be included after the default target
-include $(BUILD_SYSTEM_DIR)/makefiles/targets.mk

deps: | deps-common

update: | update-common

DEPLOYQT := linuxdeployqt-continuous-x86_64.AppImage

$(DEPLOYQT):
	wget https://github.com/probonopd/linuxdeployqt/releases/download/continuous/$(DEPLOYQT)
	chmod +x $(DEPLOYQT)

DOTHERSIDE := vendor/DOtherSide/build/lib/libDOtherSideStatic.a

$(DOTHERSIDE): | deps
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

appimage: $(APPIMAGE)

clean: | clean-common
	rm -rf $(APPIMAGE) stratus vendor/DOtherSide/build tmp/dist

endif # "variables.mk" was not included

