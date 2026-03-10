#include "pandaFramework.h"
#include "texture.h"

static volatile bool isinit = false;
// XXX: should these be volatile?
static PandaFramework framework;
static WindowFramework *window;
static NodePath aspect2d;

void DoInitialization() {
  if (isinit)
    return;

  framework.open_framework();
  framework.set_window_title("guh");
  window = framework.open_window();
  aspect2d = window->get_aspect_2d();
}

extern "C" int LLVMFuzzerTestOneInput(const char *data, size_t len) {
  // TODO: actually do something with textures
  return 0;
}
