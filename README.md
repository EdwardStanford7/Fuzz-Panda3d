# Panda3D Fuzzer

We are FUZZING this [pander](<https://github.com/panda3d/panda3d>).

## Building panda3d with AFL++ instrumentation

Currently we support MacOS through `macos_build.sh`
and GNU+Linux with `gnulinux_build.sh`.
We do not support Windows as AFL++ doesn't, especially,
and we don't support any of the BSDs as none of us use them.
If desired, we can discuss changes in this regard.

## After building panda3d...

You now should have an AFL++ compatible set of Panda3D libraries.
Change your current directory to the interface of interest,
and once there, either
- Fuzz with `make fuzz`
- triage with `make triager`

During triage we also have a helper script for large crash directories,
`triager.py` in the root of this project.

# Results

Currently we have posted the following issues to the main panda3d repository
on GitHub:

- [SEGV in pallocator](<https://github.com/panda3d/panda3d/issues/1818>)
- [SEGV in stl_tree](<https://github.com/panda3d/panda3d/issues/1819>)
- [SEGV in GeomVertexArrayFormat::is_registered](<https://github.com/panda3d/panda3d/issues/1820>)
- [SEGV in Geom::reset_geom_rendering](<https://github.com/panda3d/panda3d/issues/1821>)

### Project organization

The general workflow of fuzzing with AFL++ in this project is to first
build panda3d with AFL++ instrumentation (as specified above)
and then, with your working directory corresponding to some format you'd like to fuzz,
you can build the fuzzing harness with `make harness`.
From here we have a pattern of either `make fuzz` for single-threaded fuzzing
or `make parallel` for parallel fuzzing.
Distributed fuzzing is rather primitive for our project,
we really just have a few independent hardware nodes working at once.

Triaging is accomplished by making the `triager` binary with `make triager`,
and either using the supporting `triager.py` script in the root of this project,
or by running `./triager <crash-file>`
where `<crash-file>` is some crashing case discovered by AFL++.

