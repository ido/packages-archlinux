#!/bin/bash

which mksrcinfo \
	|| { echo "Please install a current pkgbuild-introspection."; exit -1; }

set -e
set -u

AUR4HOST=${AUR4HOST:-aur4.archlinux.org}
AUR4USER=${AUR4USER:-aur}
AUR4PORT=${AUR4PORT:-22}

REPO=${1:-}
SUBDIR=${2:-}

if [ -z "$REPO" ]; then
    echo "Usage: $0 <path to git repository> [relpath to package dirs>/]"
    echo "Example 1: $0 https://github.com/ido/packages-archlinux aur/"
    echo "           In this example, packages are in a subdir called 'aur/'."
    echo "           Go to the URL in the example to see this in the wild..."
    echo "           <relpath> MUST END IN / if provided!!!"
    echo "Example 2: $0 https://github.com/ABC/DEF"
    echo "           In this example, packages are in the root of the tree."
    echo "Copyright 2014 (c) Ido Rosen <ido@kernel.org>"
    echo "Released under dual GPL/BSD license."
    exit 1
fi

set -x
TEMP="$(mktemp -d --tmpdir importaur4.XXXXX)"
PACKAGES=()

pushd "$TEMP"
    git clone $REPO upstream
    pushd upstream
        pushd "$SUBDIR"
	for p in *; do
		if [ -f "$p/PKGBUILD" ]; then
			PACKAGES+=("$p")
		fi
	done
	popd
        for p in ${PACKAGES[@]}; do
            st="$SUBDIR$p"
            git subtree split --prefix="$st" -b aur4/$p
            git filter-branch -f --tree-filter "test -f .SRCINFO || mksrcinfo" -- aur4/$p
            ssh -p${AUR4PORT} ${AUR4USER}@${AUR4HOST} setup-repo "$p" || \
                echo "Failed to setup-repo $p ... maybe it already exists?"
            git push "ssh+git://${AUR4USER}@${AUR4HOST}:${AUR4PORT}/${p}.git/" "aur4/${p}:master" || \
                echo "git push to ${p}.git branch master failed ... maybe repo isn't empty?"
        done
    popd
    mkdir aur4-superproject
    pushd aur4-superproject
        git init .
        echo "This is a git superproject repo to track all per-package git repositories imported to AUR4." > README
        git add README
        git commit -m "Initial commit." README
        for p in ${PACKAGES[@]}; do
                git submodule add \
                    "ssh+git://${AUR4USER}@${AUR4HOST}:${AUR4PORT}/${p}.git/" "${p}"
        done
        git submodule update --init
    popd
popd

