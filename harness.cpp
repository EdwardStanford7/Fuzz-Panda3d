#include <iostream>
#include <string>
#include <vector>

#include "pandaFramework.h"

#ifndef __AFL_LOOP
#define __AFL_LOOP(x) (true) // Fallback for non-AFL builds
#endif

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <input_file>" << std::endl;
        return 1;
    }

    // Initialize Panda once (outside persistent loop)
    PandaFramework framework;
    framework.open_framework();
    framework.set_window_title("fuzz");

    WindowFramework* window = framework.open_window();
    if (!window) {
        std::cerr << "Failed to open window" << std::endl;
        return 1;
    }

    NodePath aspect2d = window->get_aspect_2d();
    std::vector<char> buf(4096);

    // Persistent fuzz loop
    while (__AFL_LOOP(1000)) {
        FILE* f = fopen(argv[1], "rb");
        if (!f) {
            perror("Failed to open input file");
            return 1;
        }

        // Read input file into buffer
        size_t len = fread(buf.data(), 1, buf.size(), f);
        fclose(f);
        if (len <= 0)
            break;

        // Create Direct-style button (PGButton is C++ backend)
        PT(PGButton) btn = new PGButton("btn");
        btn->setup(std::string(buf.data(), len)); // fuzzed text label
        btn->set_frame(-0.5, 0.5, -0.1, 0.1);

        NodePath np = aspect2d.attach_new_node(btn);

        // Force some internal processing
        btn->set_active(true);
        btn->set_active(false);

        np.remove_node();
    }

    framework.close_framework();
    return 0;
}