.PHONY: run clean

CXX = afl-clang-fast++
CXXFLAGS = -g -O1 -fno-omit-frame-pointer

INCDIR = ../panda3d/include
LIBDIR = ../panda3d/lib

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
		-lEGL \
		$(LIBDIR)/libp3framework.a \
		$(LIBDIR)/libp3tinydisplay.a \
		$(LIBDIR)/libpanda.a \
		$(LIBDIR)/libpandaexpress.a \
		$(LIBDIR)/libp3dtool.a \
		$(LIBDIR)/libp3dtoolconfig.a \
		$(LIBDIR)/libp3direct.a
endif

textnode-harness: harness.cpp
	$(CXX) $(CXXFLAGS) -fsanitize=fuzzer \
		$^ -o harness $(CCFLAGS)

textnode-triager: ../triager.cpp harness.cpp
	$(CXX) $(CXXFLAGS) -fsanitize=address \
		$^ -o triager $(CCFLAGS)

all: textnode-triager textnode-harness

run: harness
	afl-fuzz -i in -o out -- ./harness @@

clean:
	rm -f harness triager
