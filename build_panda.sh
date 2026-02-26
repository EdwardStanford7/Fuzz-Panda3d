#!/bin/bash

# MacOS specific build script for panda3d. Next Step is to generalize to Linux.

# ---- config ---
PY_INC="/opt/homebrew/opt/python@3.14/Frameworks/Python.framework/Versions/3.14/include"
PY_LIB="/opt/homebrew/opt/python@3.14/Frameworks/Python.framework/Versions/3.14/lib"

# ---- clone if needed ----
if [ ! -d "panda3d" ]; then
  git clone https://github.com/panda3d/panda3d.git panda3d
fi

cd panda3d

# ---- get third party deps for macos ----
if [ ! -d "thirdparty" ]; then
    curl -L "https://www.panda3d.org/download/panda3d-1.10.16/panda3d-1.10.16-tools-mac.tar.gz" | tar xz --strip-components=1
fi

# ---- toolchain env ----
export CC=afl-clang-fast
export CXX=afl-clang-fast++
export CFLAGS="-g -O1 -fno-omit-frame-pointer"
export CXXFLAGS="-g -O1 -fno-omit-frame-pointer"

# ---- run minimal build ----
python3 makepanda/makepanda.py --everything --static --threads 8 \
    --no-pandatool --use-direct --no-egl --no-gles --no-gles2 --no-opencv --no-ffmpeg --no-freetype --no-harfbuzz \
    --python-incdir "$PY_INC" --python-libdir "$PY_LIB"

cd ..
mkdir panda3d-built
mkdir panda3d-built/include
mkdir panda3d-built/lib
cp -r panda3d/built/include/* panda3d-built/include/
cp -r panda3d/built/lib/* panda3d-built/lib/
find panda3d/thirdparty -name "*.a" -exec cp {} panda3d-built/lib/ \;

rm -rf panda3d
mv panda3d-built panda3d
