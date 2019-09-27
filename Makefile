#!/usr/bin/make -f
ARCH := arm64
ARCH_ASFLAGS :=
ARCH_CFLAGS :=
USE_NEON := 0


# Version info
AROMA_NAME    := AROMA Installer
AROMA_VERSION := 3.00b1
AROMA_BUILD   := $(shell date +%y%m%d%H)
AROMA_CN      := Flamboyan


CC := ../TOOLCHAINS/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-gcc-4.9.4
CXX := ../TOOLCHAINS/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu--g++-4.9.4
AS := ../TOOLCHAINS/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-as
AR := ../TOOLCHAINS/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-ar

SOURCES_zlib := \
	libs/zlib/adler32.c \
	libs/zlib/crc32.c \
	libs/zlib/infback.c \
	libs/zlib/inffast.c \
	libs/zlib/inflate.c \
	libs/zlib/inftrees.c \
	libs/zlib/zutil.c
ifeq ($(USE_NEON),1)
	SOURCES_zlib += libs/zlib/inflate_fast_copy_neon.s
endif

SOURCES_libpng := \
	libs/png/png.c \
	libs/png/pngerror.c \
	libs/png/pnggccrd.c \
	libs/png/pngget.c \
	libs/png/pngmem.c \
	libs/png/pngpread.c \
	libs/png/pngread.c \
	libs/png/pngrio.c \
	libs/png/pngrtran.c \
	libs/png/pngrutil.c \
	libs/png/pngset.c \
	libs/png/pngtrans.c \
	libs/png/pngvcrd.c

ifeq ($(USE_NEON),1)
	SOURCES_libpng += libs/png/png_read_filter_row_neon.s
endif


SOURCES_minutf8 := libs/minutf8/minutf8.c

SOURCES_minzip := \
	libs/minzip/DirUtil.c \
	libs/minzip/Hash.c \
	libs/minzip/Inlines.c \
	libs/minzip/SysUtil.c \
	libs/minzip/Zip.c

SOURCES_freetype := \
	libs/freetype/autofit/autofit.c \
	libs/freetype/base/basepic.c \
	libs/freetype/base/ftapi.c \
	libs/freetype/base/ftbase.c \
	libs/freetype/base/ftbbox.c \
	libs/freetype/base/ftbitmap.c \
	libs/freetype/base/ftglyph.c \
	libs/freetype/base/ftinit.c \
	libs/freetype/base/ftpic.c \
	libs/freetype/base/ftstroke.c \
	libs/freetype/base/ftsynth.c \
	libs/freetype/base/ftsystem.c \
	libs/freetype/cff/cff.c \
	libs/freetype/pshinter/pshinter.c \
	libs/freetype/psnames/psnames.c \
	libs/freetype/raster/raster.c \
	libs/freetype/sfnt/sfnt.c \
	libs/freetype/smooth/smooth.c \
	libs/freetype/truetype/truetype.c \
	libs/freetype/base/ftlcdfil.c

SOURCES_aroma := \
	$(wildcard src/edify/*.c) \
	$(wildcard src/libs/*.c) \
	$(wildcard src/controls/*.c) \
	$(wildcard src/main/*.c)


SOURCES := $(SOURCES_zlib) $(SOURCES_libpng) $(SOURCES_minutf8) $(SOURCES_minzip) $(SOURCES_freetype) $(SOURCES_aroma)

OBJS := $(SOURCES:.c=.o)
OBJS := $(OBJS:.s=.o)

INCLUDES := -Iinclude -Isrc

AROMA_VERSION_CFLAGS := -DAROMA_NAME="\"$(AROMA_NAME)\"" -DAROMA_VERSION="\"$(AROMA_VERSION)\"" -DAROMA_BUILD="\"$(AROMA_BUILD)\"" -DAROMA_BUILD_CN="\"$(AROMA_CN)\"" $(INCLUDES)
CFLAGS := $(ARCH_CFLAGS) -O2 -static -DFT2_BUILD_LIBRARY=1 -fPIC -DPIC -fdata-sections -ffunction-sections -D_AROMA_NODEBUG $(AROMA_VERSION_CFLAGS)
ASFLAGS := $(ARCH_ASFLAGS)
LDLIBS := -lm -lpthread
LDFLAGS := --gc-sections --strip-all

all: bin/aroma_installer-$(ARCH).zip

bin/aroma_installer-$(ARCH).zip: bin/aroma_installer-$(ARCH)
	cp -RT assets tmp-zip
	cp $(@:.zip=) tmp-zip/META-INF/com/google/android/update-binary
	cp assets/META-INF/com/google/android/update-binary-installer tmp-zip/META-INF/com/google/android/update-binary-installer
	7z a $@ ./tmp-zip/*

bin/aroma_installer-$(ARCH): $(OBJS)
	mkdir -p bin
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LDLIBS)

clean:
	$(RM) $(OBJS)
	$(RM) bin/aroma_installer-$(ARCH) bin/aroma_installer-$(ARCH).zip
	$(RM) -r tmp-zip

.PHONY: clean
