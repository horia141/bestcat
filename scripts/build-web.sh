#!/bin/bash

set -ex

mkdir -p build/web
cd src/game
/Applications/Godot.app/Contents/MacOS/Godot --export-release "Web" ../../build/web/index.html  --path $(pwd) --headless
