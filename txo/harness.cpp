#include "texture.h"
#include "pandaFramework.h"

static bool initialized = false;

extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t len) {
    if (!initialized) {
        initialized = true;
        Notify::ptr()->set_ostream_ptr(new std::ofstream("/dev/null"), false);
    }

    std::string input(reinterpret_cast<const char*>(data), len);
    std::istringstream stream(input);
    
    Texture txo;

    if (!txo.read_txo(stream)) {
        return 0;
    }

    for (int i = 0; i < 3; ++i) {
        txo.generate_alpha_scale_map();
        txo.generate_ram_mipmap_images();
        txo.generate_simple_ram_image();
        txo.clear_ram_image();
    }

    txo.texture_uploaded();
    txo.clear_fullpath();
    txo.clear_alpha_fullpath();
    txo.clear_ram_image();
    txo.test_ref_count_integrity();
    txo.test_ref_count_nonzero();
    txo.mark_bam_modified();
    txo.get_bam_modified();
    txo.get_name();
    // txo.peek();
    txo.get_texture_type();
    txo.get_compression();
    txo.get_quality_level();
    txo.get_component_type();
    txo.get_format();

    std::ostringstream out;
    txo.write_txo(out);
    std::istringstream in2(out.str());
    Texture txo2;
    if (!txo2.read_txo(stream)) {
        return 0;
    }

    return 0;
}