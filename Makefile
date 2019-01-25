.DEFAULT_GOAL := all

DEPLOYQT:=linuxdeployqt-continuous-x86_64.AppImage

$(DEPLOYQT):
	wget https://github.com/probonopd/linuxdeployqt/releases/download/continuous/$(DEPLOYQT)
	chmod +x $(DEPLOYQT)

DOTHERSIDE=DOtherSide/build/lib/libDOtherSideStatic.a

$(DOTHERSIDE):
	sh build-dotherside.sh

stratus: $(DOTHERSIDE) stratus.nim
	nimble install -dy
	nim c -d:release -L:-LDOtherSide/build/lib/ stratus

APPIMAGE=Stratus-x86_64.AppImage

$(APPIMAGE): stratus $(DEPLOYQT) stratus.desktop
	rm -rf tmp/dist
	mkdir -p tmp/dist/usr/bin
	cp stratus tmp/dist/usr/bin
	cp stratus.desktop tmp/dist/stratus.desktop
	cp stratus.svg tmp/dist/stratus.svg
	cp main.qml tmp/dist/usr/bin
	./$(DEPLOYQT) tmp/dist/stratus.desktop -no-translations -no-copy-copyright-files -qmldir=tmp/dist/usr/bin -appimage

.PHONY: all
all: stratus

.PHONY: appimage
appimage: $(APPIMAGE)

.PHONY: clean
clean:
	rm -rf $(APPIMAGE) stratus DOtherSide tmp/dist

