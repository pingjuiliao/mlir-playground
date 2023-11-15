#!/bin/bash

LLVM_BIN_DIR=../../llvm-project/build/bin
LLVM_MLIR_DIR=../../llvm-project/mlir

DUMP_FILE=tmp_codegen.mlir

${LLVM_BIN_DIR}/toyc-ch2 ${LLVM_MLIR_DIR}/test/Examples/Toy/Ch2/codegen.toy -emit=mlir -mlir-print-debuginfo 2>${DUMP_FILE}
${LLVM_BIN_DIR}/toyc-ch2 ${DUMP_FILE} -emit=mlir
