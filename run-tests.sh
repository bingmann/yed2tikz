#!/bin/bash

set -e

pushd tests
for f in *.graphml; do
    ../yed2pdf $f
done
popd
    
