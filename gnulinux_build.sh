#!/bin/env bash

echo "make sure to have prerequisites installed, as described in this repo's README and in Panda3D."
sleep 0.5s

if [ ! -d "panda3d" ]; then
  git clone --recurse-submodules https://github.com/panda3d/panda3d.git panda3d
fi

cd panda3d

# export AFL++ instrumentation
export CC=afl-clang-fast
export CXX=afl-clang-fast++
export CFLAGS="-g -O1 -fno-omit-frame-pointer"
export CXXFLAGS="-g -O1 -fno-omit-frame-pointer"

python3 makepanda/makepanda.py \
  --everything --static --threads $(nproc) \
  --no-pandatool --use-direct --no-egl --no-gles --no-gles2 --no-opencv --no-ffmpeg --no-freetype --no-harfbuzz

