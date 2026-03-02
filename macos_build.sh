#!/bin/bash

# MacOS specific build script for panda3d. Next Step is to generalize to Linux.

# ---- config ---
export PY_INC="/opt/homebrew/opt/python@3.14/Frameworks/Python.framework/Versions/3.14/include"
export PY_LIB="/opt/homebrew/opt/python@3.14/Frameworks/Python.framework/Versions/3.14/lib"

# ---- get third party deps for macos ----
if [ ! -d "thirdparty" ]; then
    curl -L "https://www.panda3d.org/download/panda3d-1.10.16/panda3d-1.10.16-tools-mac.tar.gz" | tar xz --strip-components=1
fi

./build.sh

