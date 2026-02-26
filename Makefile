.PHONY: all clean run

CXX = afl-clang-fast++
CXXFLAGS = -g -O1 -fno-omit-frame-pointer
INCDIR = panda3d/include
LIBDIR = panda3d/lib

# MacOS specific, super complicated linking flags to force load all the necessary libraries.
# Examine ways to simplify this in the future, but for now it works.
harness: harness.cpp
	$(CXX) $(CXXFLAGS) harness.cpp -o harness \
	-I$(INCDIR) \
	-Wl,-force_load,$(LIBDIR)/libp3framework.a \
	-Wl,-force_load,$(LIBDIR)/libpanda.a \
	-Wl,-force_load,$(LIBDIR)/libpandaexpress.a \
	-Wl,-force_load,$(LIBDIR)/libp3dtool.a \
	-Wl,-force_load,$(LIBDIR)/libp3dtoolconfig.a \
	-Wl,-force_load,$(LIBDIR)/libp3direct.a \
	-Wl,-force_load,$(LIBDIR)/libpandagl.a \
	-Wl,-force_load,$(LIBDIR)/libpandaegg.a \
	-L$(LIBDIR) \
	-lssl -lcrypto \
	-lpng \
	-ljpeg \
	-lz \
	-ltiff \
	-lIlmImf -lIex -lHalf -lIlmThread \
	-lsquish \
	-lopusfile -lopus \
	-lvorbisfile -lvorbis -logg \
	-lobjc \
	-framework CoreFoundation \
	-framework CoreVideo \
	-framework Carbon \
	-framework IOKit \
	-framework AppKit \
	-framework OpenGL \
	-framework CoreServices \
	-framework CoreAudio \
	-framework AudioUnit \
	-framework SystemConfiguration

fuzz: harness
	afl-fuzz -i in -o out -- ./harness @@

clean:
	rm -f harness