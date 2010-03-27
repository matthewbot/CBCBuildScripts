###### Globals ######
ROOT := /mnt/kiss
REAL_ROOT := /opt/chumbyqt
QT_PREFIX := $(ROOT)/qt

all: qt

####### tslib #######

TSLIB_SOURCE := src/tslib-1.0
TSLIB_BUILD := build/tslib
TSLIB_DOWNLOAD := downloads/tslib-1.0.tar.bz2
TSLIB_URL := http://download.berlios.de/tslib/tslib-1.0.tar.bz2
TSLIB_CONFIG := --prefix=$(QT_PREFIX) --host=arm-linux
TSLIB_FLAG := flags/built-tslib
TSLIB_SOURCE_FLAG := flags/extracted-tslib

$(TSLIB_FLAG): $(TSLIB_SOURCE_FLAG) $(ROOT)
	mkdir -p $(TSLIB_BUILD)
	(cd $(TSLIB_BUILD); ../../$(TSLIB_SOURCE)/configure $(TSLIB_CONFIG))
	patch -p1 -d $(TSLIB_BUILD) < patches/tslib-no-rpl-malloc.patch
	$(MAKE) -C $(TSLIB_BUILD)
	sudo make -C $(TSLIB_BUILD) install
	mkdir -p flags
	touch $(TSLIB_FLAG)

$(TSLIB_SOURCE_FLAG): $(TSLIB_DOWNLOAD)
	mkdir -p src
	tar -xjf $(TSLIB_DOWNLOAD) -C src
	(cd $(TSLIB_SOURCE); ./autogen.sh)
	mkdir -p flags
	touch $(TSLIB_SOURCE_FLAG)

$(TSLIB_DOWNLOAD):
	wget -q $(TSLIB_URL) -P downloads

#### QT Embedded ####

QT_SOURCE := src/qt-embedded-linux-opensource-src-4.5.2
QT_BUILD := build/qt
QT_DOWNLOAD := downloads/qt-embedded-linux-opensource-src-4.5.2.tar.gz
QT_URL := ftp://ftp.qt.nokia.com/qt/source/qt-embedded-linux-opensource-src-4.5.2.tar.gz
QT_CONFIG := -embedded arm -pch -prefix $(QT_PREFIX) -opensource -fast \
             -qt-kbd-usb -qt-mouse-tslib -no-glib -no-opengl \
             -L$(QT_PREFIX)/lib -I$(QT_PREFIX)/include \
             -nomake examples -nomake demos \
             -no-webkit -no-phonon -no-phonon-backend -no-scripttools -no-svg \
             -no-qt3support -no-xmlpatterns -no-largefile \
             -no-cups -no-iconv -no-dbus -reduce-relocations
QT_FLAG := flags/built-qt
QT_SOURCE_FLAG := flags/extracted-qt
QT_CONFIGURE_FLAG := flags/configured-qt

$(QT_FLAG): $(QT_CONFIGURE_FLAG)
	$(MAKE) -C $(QT_BUILD)
	sudo make -C $(QT_BUILD) install
	mkdir -p flags
	touch $(QT_FLAG)
	
$(QT_CONFIGURE_FLAG): $(QT_SOURCE_FLAG) $(TSLIB_FLAG) $(ROOT)
	mkdir -p $(QT_BUILD)
	(cd $(QT_BUILD); ../../$(QT_SOURCE)/configure $(QT_CONFIG))	
	mkdir -p flags
	touch $(QT_CONFIGURE_FLAG)

$(QT_SOURCE_FLAG): $(QT_DOWNLOAD)
	mkdir -p src
	tar -xzf $(QT_DOWNLOAD) -C src
	mkdir -p flags
	touch $(QT_SOURCE_FLAG)

$(QT_DOWNLOAD):
	wget -q $(QT_URL) -P downloads
	
#### Not Chroot #####
# This is an ugly hack, but it works. I also suspect its how KIPR does things,
# but maybe not. Instead of doing a proper chroot build like you should for
# embedded linux, this sets up /opt/chumbyqt to hold the arm libraries, and
# makes /mnt/kiss a symlink to it. This is needed because the linker expects to
# find the various libraries and headers in their correct location (/mnt/kiss),
# even while building. 

$(ROOT):
	sudo mkdir -p $(REAL_ROOT)
	sudo ln -s $(REAL_ROOT) $(ROOT)
	
#### Main rules ####

.PHONY: qt
qt: $(QT_FLAG)

.PHONY: tslib
tslib: $(TSLIB_FLAG)

clean:
	rm -rf src flags
	
dist-clean: clean
	rm -rf downloads
	
uninstall:
	sudo rm -rf /opt/chumbyqt /mnt/kiss
	
