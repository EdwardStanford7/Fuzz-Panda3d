#!/usr/bin/env bash

echo "make sure to have prerequisites installed, as described in this repo's README and in Panda3D."
sleep 0.5s

# ---- clone if needed ----
if [ ! -d "panda3d" ]; then
  git clone https://github.com/panda3d/panda3d.git panda3d
fi

# ---- if thirdparty deps are present move them into the panda3d repo ----
if [ -d "thirdparty" ]; then
    mv thirdparty panda3d/thirdparty
fi

cd panda3d

# ---- toolchain env ----
export CC=afl-clang-fast
export CXX=afl-clang-fast++
export CFLAGS="-g -O1 -fno-omit-frame-pointer"
export CXXFLAGS="-g -O1 -fno-omit-frame-pointer"

# ---- run minimal build ----
if [ -n "${PY_INC+x}" ]; then
python3 makepanda/makepanda.py --everything --static --threads $(nproc) \
    --no-pandatool --use-direct --no-egl --no-gles --no-gles2 --no-opencv --no-ffmpeg --no-freetype --no-harfbuzz \
    --python-incdir "$PY_INC" --python-libdir "$PY_LIB"
    
else
  python3 makepanda/makepanda.py --nothing --use-direct --static --threads $(nproc)
fi

cd ..
mkdir panda3d-built
mkdir panda3d-built/include
mkdir panda3d-built/lib
cp -r panda3d/built/include/* panda3d-built/include/
cp -r panda3d/built/lib/* panda3d-built/lib/
find panda3d/thirdparty -name "*.a" -exec cp {} panda3d-built/lib/ \;

# previously this removed the entire panda3d repo and placed the "built" directory
# where that previously was. This is difficult for debugging,
# so in these early stages I'm just shuffing this around.
mv panda3d panda3d-fullrepo
mv panda3d-built panda3d
