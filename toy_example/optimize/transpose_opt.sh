#!/bin/bash

LLVM_BIN_DIR=../../llvm-project/build/bin
LLVM_MLIR_DIR=../../llvm-project/mlir

# emit without optimize
echo "=== Without Optimization ========================================================================"
${LLVM_BIN_DIR}/toyc-ch3 ${LLVM_MLIR_DIR}/test/Examples/Toy/Ch3/transpose_transpose.toy -emit=mlir

echo "=== With Optimization ===================================================================================="
${LLVM_BIN_DIR}/toyc-ch3 ${LLVM_MLIR_DIR}/test/Examples/Toy/Ch3/transpose_transpose.toy -emit=mlir -opt
