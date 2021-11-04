#!/bin/bash
python3.9 "build_tools/build_tools.py" -o "lib" --startup-script "startup/02_load_apis.lua" --relative-imports --link -v "lib/.fredio" "lib/.frednet"