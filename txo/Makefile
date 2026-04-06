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
		-lp3framework -lpandaegg -lpanda -lpandaexpress -lp3dtool -lp3dtoolconfig -lp3direct
endif

run: harness
	afl-fuzz -x egg.dict -i in -o out -- ./harness @@

harness: harness.cpp
	$(CXX) $(CXXFLAGS) -fsanitize=fuzzer \
		$^ -o harness $(CCFLAGS)

triager: ../triager.cpp harness.cpp
	$(CXX) $(CXXFLAGS) -fsanitize=address \
		$^ -o triager $(CCFLAGS)

parallel: harness
	export AFL_TESTCACHE_SIZE=10000
	export AFL_NO_AFFINITY
	(AFL_NO_UI=1 \
		afl-fuzz -S secondary-1 -i in -o out ./harness @@ >> /dev/null) &
	(AFL_NO_UI=1 \
		afl-fuzz -S secondary-2 -i in -o out ./harness @@ >> /dev/null) &
	(AFL_NO_UI=1 \
		afl-fuzz -S secondary-3 -i in -o out ./harness @@ >> /dev/null) &
	(AFL_NO_UI=1 \
		afl-fuzz -S secondary-4 -i in -o out ./harness @@ >> /dev/null) &
	(AFL_NO_UI=1 \
		afl-fuzz -S secondary-5 -i in -o out ./harness @@ >> /dev/null) &
	(AFL_NO_UI=1 \
		afl-fuzz -S secondary-6 -i in -o out ./harness @@ >> /dev/null) &
	(AFL_NO_UI=1 \
		afl-fuzz -S secondary-7 -i in -o out ./harness @@ >> /dev/null) &
	(AFL_IMPORT_FIRST=1 AFL_FINAL_SYNC=1 \
		afl-fuzz -M main-$(HOSTNAME) -i in -o out ./harness @@)

clean:
	rm -f harness triager

