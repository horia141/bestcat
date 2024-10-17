#!/bin/bash

set -ex

mkdir -p build/web
/Applications/Godot.app/Contents/MacOS/Godot --export-release "Web" build/web/index.html  --path $(pwd) --headless
