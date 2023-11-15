#!/bin/bash

LLVM_BIN_DIR=../../llvm-project/build/bin
LLVM_MLIR_DIR=../../llvm-project/mlir

${LLVM_BIN_DIR}/toyc-ch1 ${LLVM_MLIR_DIR}/test/Examples/Toy/Ch1/ast.toy -emit=ast
