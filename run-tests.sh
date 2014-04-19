#!/bin/bash

set -e

pushd tests
for f in *.graphml; do

    if [[ $f == bare* ]]; then
        ../yed2pdf $f --param bare 1
    else
        ../yed2pdf $f
    fi

done
rm *.log *.aux
popd
    
