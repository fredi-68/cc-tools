# cc-tools

This repository contains a collection of libraries, scripts and tools I made for developing ComputerCraft programs.
This includes:
- a complete custom network stack (RedNet replacement) with support for assignable addresses, port multiplexing and other features
- a class utility for creating classes
- a logging library
- a framework for asynchronous programming with tasks based on coroutines
- a python script for resolving relative imports and linking multiple files into one API for easy loading during boot.

# build_tools

The `build_and_link.sh` shell script handles the linking and deployment of the libraries in my custom source repository setup. 
It will most likely not work for other directory structures.