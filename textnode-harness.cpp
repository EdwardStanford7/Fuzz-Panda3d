#include "pandaFramework.h"
#include "textNode.h"
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
  framework.set_window_title("fuzz");
  window = framework.open_window();
  if (!window) {
    std::cerr << "(!) Failed to open window" << std::endl;
  }
  aspect2d = window->get_aspect_2d();
}

extern "C" int LLVMFuzzerTestOneInput(const char *data, size_t len) {
  DoInitialization();
  // Create Direct-style button (PGButton is C++ backend)
  PT(PGButton) btn = new PGButton("btn");
  // btn->setup(std::string("fuzz", 5)); // fuzzed text label
  btn->setup(std::string(data, len)); // fuzzed text label
  btn->set_frame(-0.5, 0.5, -0.1, 0.1);

  NodePath np = aspect2d.attach_new_node(btn);
  // create a text node similarly to how direct onscreentext would
  PT(TextNode) textNode = new TextNode("text");
  textNode->set_text(std::string(data, len));
  np.attach_new_node(textNode);
  // Force some internal processing
  btn->set_active(true);
  btn->set_active(false);
  textNode->set_card_decal(false);
  textNode->set_card_decal(true);

  np.remove_node();

  framework.set_exit_flag();
  framework.main_loop();

  delete btn;
  return 0;
}
