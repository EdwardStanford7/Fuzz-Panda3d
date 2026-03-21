.PHONY: run clean

CXX = afl-clang-fast++
CXXFLAGS = -g -O1 -fno-omit-frame-pointer

INCDIR = ../panda3d/include
LIBDIR = ../panda3d/lib

UNAME_S := $(shell uname -s)

CCFLAGS :=
ifeq ($(UNAME_S),Darwin) # MacOS
	CCFLAGS += \
		-I$(INCDIR) \
		-L$(LIBDIR) \
		-lp3framework -lpanda -lpandaexpress -lp3dtool -lp3dtoolconfig -lp3direct -lpandaegg \
		-lssl -lcrypto -lpng -ljpeg -lz -ltiff -lIex -lIlmThread -lsquish -lopusfile -lopus -lvorbisfile -lvorbis -logg -lobjc -lIlmImf -lHalf \
		-framework CoreVideo -framework Carbon -framework IOKit -framework AppKit -framework OpenGL
else # GNU+Linux
	CCFLAGS += \
		-I$(INCDIR) \
		-L$(LIBDIR) \
		-lEGL \
		-lp3framework -lpanda -lpandaexpress -lp3dtool -lp3dtoolconfig -lp3direct -lpandaegg
endif

run: harness
	afl-fuzz -x egg.dict -i in -o out -- ./harness @@

harness: harness.cpp
	$(CXX) $(CXXFLAGS) -fsanitize=fuzzer \
		$^ -o harness $(CCFLAGS)

clean:
	rm -f harness
