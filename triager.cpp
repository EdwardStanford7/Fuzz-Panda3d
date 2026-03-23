#include "sharehack.h"
#include <cstring>
#include <fstream>
#include <iostream>
#include <unistd.h>
#include <vector>

std::vector<char> read_file(char *path) {
  std::ifstream file(path, std::ios::binary | std::ios::ate);
  std::streamsize size = file.tellg();
  file.seekg(0, std::ios::beg);

  std::vector<char> buffer(size);
  if (!file.read(buffer.data(), size)) {
    std::cout << "(.) couldn't read from file" << path << std::endl;
    exit(-1);
  }

  return buffer;
}

// TODO: change input
int main(int argc, char *argv[]) {
  if (argc < 2) {
    std::cout << "(.) need to provide an arg to the triager" << std::endl;
    return -1;
  }
  std::vector<char> buf = read_file(argv[1]);
  return LLVMFuzzerTestOneInput(buf.data(), buf.size());
}
