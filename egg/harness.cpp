#include "eggData.h"

static bool initialized = false;

extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t len) {
    if (!initialized) {
        initialized = true;
        Notify::ptr()->set_ostream_ptr(new std::ofstream("/dev/null"), false);
    }

    std::string input(reinterpret_cast<const char*>(data), len);
    std::istringstream stream(input);

    EggData egg;

    if (!egg.read(stream)) {
        return 0;
    }

    for (int i = 0; i < 3; ++i) {
        egg.triangulate_polygons(EggData::T_polygon | EggData::T_convex);
        egg.recompute_vertex_normals(0.05);
        egg.remove_unused_vertices(true);
    }

    egg.flatten_transforms();
    egg.apply_texmats();
    egg.strip_normals();
    egg.unify_attributes(true, true, true);
    egg.recompute_polygon_normals();
    egg.reverse_vertex_ordering();
    egg.remove_invalid_primitives(true);
    egg.remove_unused_vertices(true);

    std::ostringstream out;
    egg.write_egg(out);
    std::istringstream in2(out.str());
    EggData egg2;
    if (!egg2.read(in2))
        return 0;

    return 0;
}