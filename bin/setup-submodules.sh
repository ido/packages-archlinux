#!/bin/bash

git submodule update --init --rebase --recursive
for i in `cd aur4; ls`; do
    pushd aur4/$i
        git config remote.origin.pushurl ssh://aur@aur4.archlinux.org/${i}.git
    popd
done
