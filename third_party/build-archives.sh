#!/bin/sh
# Copyright The OWASP Coraza contributors
# SPDX-License-Identifier: Apache-2.0
#
# Rebuilds the prebuilt wasm32 archives linked by the TinyGo build from source:
#   go-re2/internal/wasm/libcre2.a       (Rust regex + aho-corasick, buildtools/cre2)
#   go-libinjection/wasm/libinjection.a  (libinjection C, buildtools/libinjection)
# CI runs this and fails if the result differs from the committed archives.
set -eu
cd "$(dirname "$0")"

docker build --platform linux/amd64 --target artifact \
  -o type=local,dest=go-re2/internal/wasm go-re2/buildtools/cre2

docker build --platform linux/amd64 -t coraza-libinjection-build go-libinjection/buildtools/libinjection
docker run --rm --platform linux/amd64 -v "$PWD/go-libinjection/wasm:/out" coraza-libinjection-build
