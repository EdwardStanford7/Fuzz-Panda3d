.PHONY: run clean

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
		-lp3framework -lpanda -lpandaexpress -lp3dtool -lp3dtoolconfig -lp3direct  \
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
		$(LIBDIR)/libpanda.a \
		$(LIBDIR)/libpandaexpress.a \
		$(LIBDIR)/libp3dtool.a \
		$(LIBDIR)/libp3dtoolconfig.a \
		$(LIBDIR)/libp3direct.a
endif

textnode-harness: textnode-harness.cpp
	$(CXX) $(CXXFLAGS) -fsanitize=fuzzer \
		textnode-harness.cpp -o harness $(CCFLAGS)

texture-harness: texture-harness.cpp
	$(CXX) $(CXXFLAGS) -fsanitize=fuzzer \
		texture-harness.cpp -o harness $(CCFLAGS)

textnode-triager: triager.cpp textnode-harness.cpp
	$(CXX) $(CXXFLAGS) -fsanitize=address \
		triager.cpp \
		textnode-harness.cpp -o triager $(CCFLAGS)

texture-triager: triager.cpp texture-harness.cpp
	$(CXX) $(CXXFLAGS) -fsanitize=address \
		triager.cpp \
		texture-harness.cpp -o triager $(CCFLAGS)

texture: texture-harness texture-triager

textnode: textnode-harness textnode-triager

run: harness
	afl-fuzz -i in -o out -- ./harness @@

clean:
	rm -f harness triager
