#!/bin/sh
set -e

# this script writes out two files:
#  - generated/webgl_bindings.js
#  - generated/webgl.zig
zig run tools/webgl_generate.zig

(echo; cat webgl_constants.zig) >> generated/webgl.zig
