#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p scratch
sysl test .
for target in thumbv6m-freestanding thumbv7em-freestanding thumb-freestanding riscv32-freestanding aarch64-freestanding; do
    sysl build-c tools/portable --target "$target" -o "scratch/wav-$target.a"
done
