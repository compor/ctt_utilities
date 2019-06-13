#!/usr/bin/env bash

CC=`which clang`

CLANG_OPTIONS=""
CLANG_OPTIONS="${CLANG_OPTIONS} -O2"
CLANG_OPTIONS="${CLANG_OPTIONS} -fno-unroll-loops"
CLANG_OPTIONS="${CLANG_OPTIONS} -fno-vectorize"
CLANG_OPTIONS="${CLANG_OPTIONS} -fno-slp-vectorize"
CLANG_OPTIONS="${CLANG_OPTIONS} -g -gline-tables-only"
CLANG_OPTIONS="${CLANG_OPTIONS} -c -S -emit-llvm"

FILE_STEM=${1%*.c}

${CC} \
  ${CLANG_OPTIONS} \
  "${1}"

[[ ! -z $? ]] && mv ${FILE_STEM}.ll ${FILE_STEM}.opt2.ll

