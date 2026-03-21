#include "pgButton.h"
#include "textNode.h"

bool fuzzTextNode(const char *data, size_t len) {
  char random_char = len >= 1 ? data[0] : '\0';

  PT(TextNode) textNode = new TextNode("text");
  textNode->set_text(std::string(data, len));
  textNode->set_card_decal(false);
  textNode->set_card_decal(true);

  if (!(textNode->get_bin() == ""))
    return false;

  textNode->set_bin(std::string(data, len));
  if (!(textNode->get_bin() == std::string(data, len)))
    return false;
  textNode->clear_bin();
  if (!(textNode->get_bin() == ""))
    return false;
  textNode->set_bin(std::string(data, len));
  if (!(textNode->get_bin() == std::string(data, len)))
    return false;

  textNode->calc_width(random_char);

  textNode->get_align();
  textNode->clear_align();
  TextNode::Alignment alignment = (TextNode::Alignment)(random_char % 5);
  textNode->set_align(alignment);

  textNode->get_card_color();
  textNode->get_card_as_set();

  textNode->update();
  textNode->force_update();
  textNode->clear();

  return true;
}

bool fuzzPGButton(const char *data, size_t len) {
  PT(PGButton) btn = new PGButton("btn");
  btn->setup(std::string(data, len)); // fuzzed text label
  btn->set_frame(-0.5, 0.5, -0.1, 0.1);
  btn->set_active(true);
  btn->set_active(false);

  return true;
}

extern "C" int LLVMFuzzerTestOneInput(const char *data, size_t len) {
  bool res;
  [[clang::always_inline]] res = fuzzTextNode(data, len);
  if (!res)
    return -1;

  [[clang::always_inline]] res = fuzzPGButton(data, len);
  if (!res)
    return -1;
  return 0;
}
