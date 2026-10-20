#!/bin/bash
set -x -euo pipefail

out=gh-pages
origin=$(git remote get-url origin)

test -d gh-pages && rm -rf gh-pages
mkdir -p gh-pages
cp -R result/. "$out/"
chmod -R 755 gh-pages

pushd "$out/" && {
    touch .nojekyll
    echo "arcane-marketplace.socheat.dev" > CNAME

    git init
    git remote add origin "$origin"
    git add .
    git commit -m "generate gh-pages $(date +'%Y-%m-%d %H:%M:%S')"
    git push -u origin main:gh-pages --force
    popd
}
rm -rf "$out" || true
