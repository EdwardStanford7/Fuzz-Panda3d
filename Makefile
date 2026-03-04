.PHONY: all run clean

CXX = afl-clang-fast++
CXXFLAGS = -g -O1 -fno-omit-frame-pointer

INCDIR = panda3d/include
LIBDIR = panda3d/lib

UNAME_S := $(shell uname -s)

CCFLAGS :=
ifeq ($(UNAME_S),Darwin)
	CCFLAGS += \
		-I$(INCDIR) \
		-L$(LIBDIR) \
		-lp3framework -lpanda -lpandaexpress -lp3dtool -lp3dtoolconfig -lp3direct -lpandagl -lpandaegg \
		-lssl -lcrypto -lpng -ljpeg -lz -ltiff -lIex -lIlmThread -lsquish -lopusfile -lopus -lvorbisfile -lvorbis -logg -lobjc -lIlmImf -lHalf \
		-framework CoreVideo \
		-framework Carbon \
		-framework IOKit \
		-framework AppKit \
		-framework OpenGL
else # GNU+Linux
	CCFLAGS += \
		-I$(INCDIR) \
		$(LIBDIR)/libp3framework.a \
		$(LIBDIR)/libpandagl.a \
		$(LIBDIR)/libpandaegg.a \
		$(LIBDIR)/libpanda.a \
		$(LIBDIR)/libpandaexpress.a \
		$(LIBDIR)/libp3dtool.a \
		$(LIBDIR)/libp3dtoolconfig.a \
		$(LIBDIR)/libp3direct.a \
		-lssl -lcrypto \
		-lpng \
		-ljpeg \
		-lz \
		-ltiff \
		-lIex -lIlmThread \
		-lsquish \
		-lopusfile -lopus \
		-lvorbisfile -lvorbis -logg \
		-lobjc \
		-lX11 \
		-lGL \
		-lOpenEXR -lImath
endif

all: harness

harness: harness.cpp
	$(CXX) $(CXXFLAGS) harness.cpp -o harness $(CCFLAGS)

run: harness
	afl-fuzz -i in -o out -- ./harness @@

clean:
	rm -f harness