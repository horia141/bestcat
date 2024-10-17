#!/bin/bash 

set -ex

cd src/local-serve-web
uvicorn main:app --reload
