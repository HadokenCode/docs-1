#!/bin/bash

# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

install () {
    test -d tmp || mkdir tmp
    git clone https://github.com/tsuru/tsuru.git tmp/tsuru
    pushd tmp/tsuru
    pip install -r requirements.txt
    popd
    mkdir -p build
    mkdir -p tmp/tsuru/worktree
}

# generate version commit
generate () {
    version=$1
    commit=$2

    pushd tmp/tsuru
    if [[ $commit == "master" ]]; then
        ln -s `pwd` worktree/v$commit
    else
        git worktree add worktree/v$commit $commit
    fi
    pushd worktree/v${commit}/docs
    make html
    popd
    popd
    cp -rp tmp/tsuru/worktree/v${commit}/docs/_build/html/ build/$version
    pushd tmp/tsuru/worktree/v${commit}/docs
    make clean
    popd
}

function copy_deploy_files {
    cp nginx.conf build
    cp tsuru.yaml build
}

clean () {
    rm -rf tmp
}

install

generate master master &
generate latest 1.1.0-rc2 &
generate stable 1.0.1 &
generate 1.1.0 1.1.0-rc2 &
generate 1.0.1 1.0.1 &
generate 1.0.0 1.0.0 &
generate 0.13 0.13.0 &
generate 0.12 0.12.4 &
generate 0.11 0.11.3 &
generate 0.10 0.10.3 &
generate 0.9 0.9.1 &
generate 0.8 0.8.2 &
generate 0.7 0.7.2 &
generate 0.6 0.6.2 &
generate 0.5 0.5.3 &
generate 0.4 0.4.0 &
generate 0.3 0.3.12 &
generate 0.2 0.2.12 &
generate 0.1 0.1.0 &

for job in `jobs -p`; do
    wait $job || exit 1
done

copy_deploy_files

clean
