#!/bin/bash

set -ex

mkdir -p build/macos
/Applications/Godot.app/Contents/MacOS/Godot --export-release "macOS" build/macos/BestCat.dmg  --path $(pwd) --headless