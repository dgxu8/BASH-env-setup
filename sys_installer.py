#!/usr/bin/env python3

import argparse

# Yaml imports
from yaml import load, dump
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper


TEST_STREAM = """
test: &testing
    thing: 1
    things: 2
checkit:
    <<: *testing
    things: 3
    test: >
        curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[0-35.]+'
test:
    - cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release
      -DCMAKE_PREFIX_PATH=/usr/lib/llvm-10
      -DLLVM_INCLUDE_DIR=/usr/lib/llvm-10/include
      -DLLVM_BUILD_INCLUDE_DIR=/usr/include/llvm-10/
"""


def main():
    data = load(TEST_STREAM, Loader=Loader)
    print(str(data))


if __name__ == "__main__":
    main()
