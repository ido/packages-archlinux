#!/bin/bash

### From https://raw.githubusercontent.com/falconindy/pkgbuild-introspection :

array_build() {
  local dest=$1 src=$2 i keys values

  # it's an error to try to copy a value which doesn't exist.
  declare -p "$2" &>/dev/null || return 1

  # Build an array of the indicies of the source array.
  eval "keys=(\"\${!$2[@]}\")"

  # Read values indirectly via their index. This approach gives us support
  # for associative arrays, sparse arrays, and empty strings as elements.
  for i in "${keys[@]}"; do
    values+=("printf -v '$dest[$i]' %s \"\${$src[$i]}\";")
  done

  eval "${values[*]}"
}

funcgrep() {
  { declare -f "$1" || declare -f package; } 2>/dev/null | grep -E "$2"
}

extract_global_var() {
  # $1: variable name
  # $2: multivalued
  # $3: name of output var

  local attr=$1 isarray=$2 outputvar=$3

  if (( isarray )); then
    declare -n ref=$attr
    # Still need to use array_build here because we can't handle the scoping
    # semantics that would be included with the use of 'declare -n'.
    [[ ${ref[@]} ]] && array_build "$outputvar" "$attr"
  else
    [[ ${!attr} ]] && printf -v "$outputvar" %s "${!attr}"
  fi
}

extract_function_var() {
  # $1: function name
  # $2: variable name
  # $3: multivalued
  # $4: name of output var

  local funcname=$1 attr=$2 isarray=$3 outputvar=$4 attr_regex= decl= r=1

  if (( isarray )); then
    printf -v attr_regex '^[[:space:]]* %s\+?=\(' "$2"
  else
    printf -v attr_regex '^[[:space:]]* %s\+?=[^(]' "$2"
  fi

  while read -r; do
    # strip leading whitespace and any usage of declare
    decl=${REPLY##*([[:space:]])}
    eval "${decl/#$attr/$outputvar}"

    # entering this loop at all means we found a match, so notify the caller.
    r=0
  done < <(funcgrep "$funcname" "$attr_regex")

  return $r
}

pkgbuild_get_attribute() {
  # $1: package name
  # $2: attribute name
  # $3: multivalued
  # $4: name of output var

  local pkgname=$1 attrname=$2 isarray=$3 outputvar=$4

  printf -v "$outputvar" %s ''

  if [[ $pkgname ]]; then
    extract_global_var "$attrname" "$isarray" "$outputvar"
    extract_function_var "package_$pkgname" "$attrname" "$isarray" "$outputvar"
  else
    extract_global_var "$attrname" "$isarray" "$outputvar"
  fi
}

srcinfo_open_section() {
  printf '%s = %s\n' "$1" "$2"
}

srcinfo_close_section() {
  echo
}

srcinfo_write_attr() {
  # $1: attr name
  # $2: attr values

  local attrname=$1 attrvalues=("${@:2}")

  # normalize whitespace, strip leading and trailing
  attrvalues=("${attrvalues[@]//+([[:space:]])/ }")
  attrvalues=("${attrvalues[@]#[[:space:]]}")
  attrvalues=("${attrvalues[@]%[[:space:]]}")

  printf "\t$attrname = %s\n" "${attrvalues[@]}"
}

pkgbuild_extract_to_srcinfo() {
  # $1: pkgname
  # $2: attr name
  # $3: multivalued

  local pkgname=$1 attrname=$2 isarray=$3 outvalue=

  if pkgbuild_get_attribute "$pkgname" "$attrname" "$isarray" 'outvalue'; then
    srcinfo_write_attr "$attrname" "${outvalue[@]}"
  fi
}

srcinfo_write_section_details() {
  local attr package_arch a
  local multivalued_arch_attrs=(source provides conflicts depends replaces
                                optdepends makedepends checkdepends
                                {md5,sha{1,224,256,384,512}}sums)

  for attr in "${singlevalued[@]}"; do
    pkgbuild_extract_to_srcinfo "$1" "$attr" 0
  done

  for attr in "${multivalued[@]}"; do
    pkgbuild_extract_to_srcinfo "$1" "$attr" 1
  done

  pkgbuild_get_attribute "$1" 'arch' 1 'package_arch'
  for a in "${package_arch[@]}"; do
    # 'any' is special. there's no support for, e.g. depends_any.
    [[ $a = any ]] && continue

    for attr in "${multivalued_arch_attrs[@]}"; do
      pkgbuild_extract_to_srcinfo "$1" "${attr}_$a" 1
    done
  done
}

srcinfo_write_global() {
  local singlevalued=(pkgdesc pkgver pkgrel epoch url install changelog)
  local multivalued=(arch groups license checkdepends makedepends
                     depends optdepends provides conflicts replaces
                     noextract options backup
                     source {md5,sha{1,224,256,384,512}}sums)

  srcinfo_open_section 'pkgbase' "${pkgbase:-$pkgname}"
  srcinfo_write_section_details ''
  srcinfo_close_section
}

srcinfo_write_package() {
  local singlevalued=(pkgdesc url install changelog)
  local multivalued=(arch groups license checkdepends depends optdepends
                     provides conflicts replaces options backup)

  srcinfo_open_section 'pkgname' "$1"
  srcinfo_write_section_details "$1"
  srcinfo_close_section
}

srcinfo_write() {
  local pkg

  srcinfo_write_global

  for pkg in "${pkgname[@]}"; do
    srcinfo_write_package "$pkg"
  done
}

clear_environment() {
  local environ

  mapfile -t environ < <(compgen -A variable |
      grep -xvF "$(printf '%s\n' "$@")")

  # expect that some variables marked read only will complain here
  unset -v "${environ[@]}" 2>/dev/null
}

srcinfo_write_from_pkgbuild() {(
  clear_environment PATH

  shopt -u extglob
  . "$1" || exit 1
  shopt -s extglob
  srcinfo_write
)}

### import-to-aur4:

set -e
set -u
set -x

AUR4HOST=${AUR4HOST:-aur-dev.archlinux.org}
AUR4USER=${AUR4USER:-aur}
AUR4PORT=${AUR4PORT:-2222}

REPO=${1:-}
SUBDIR=${2:-}

if [ -z "$REPO" -o -z "$SUBDIR" ]; then
    echo "Usage: $0 <path to git repository> <relpath to package dirs>"
    echo "Example 1: $0 https://github.com/ido/packages-archlinux aur"
    echo "           In this example, packages are in a subdir called 'aur'."
    echo "           Go to the URL in the example to see this in the wild..."
    echo "Example 2: $0 https://github.com/ABC/DEF ."
    echo "           In this example, packages are in the root of the tree."
    echo "Copyright 2014 (c) Ido Rosen <ido@kernel.org>"
    echo "Released under dual GPL/BSD license."
    exit 1
fi

TEMP="$(mktemp -d --tmpdir importaur4.XXXXX)"
PACKAGES=()
PKGBUILDS=()
SRCINFOS=()

pushd "$TEMP"
    git clone $REPO upstream
    pushd upstream
        pushd "$SUBDIR"
            for p in *; do
                if [ -f "$p/PKGBUILD" ]; then
                    PACKAGES+=("$p")
                    PKGBUILDS+=("$p/PKGBUILD")
                    SRCINFOS+=("$p/.SRCINFO")
                    if [ ! -f "$p/.SRCINFO" ]; then
                        pushd "$p"
                            shopt -s extglob
                            set +e +u +x
                            srcinfo_write_from_pkgbuild PKGBUILD > "$TEMP/SRCINFO-$p"
                            set -e -u -x
                            shopt -u extglob
                        popd
                    fi
                fi
            done
        popd
        for p in ${PACKAGES[@]}; do
            st="$SUBDIR/$p"
            git subtree split --prefix="$st" -b aur4/$p
            git filter-branch -f --tree-filter "test -f .SRCINFO || cp $TEMP/SRCINFO-$p .SRCINFO" -- aur4/$p
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

