#!/bin/bash

LLVM_BIN_DIR=../../llvm-project/build/bin
LLVM_MLIR_DIR=../../llvm-project/mlir

DUMP_FILE=tmp_codegen.mlir

echo "=== Dump MLIR ========================"
${LLVM_BIN_DIR}/toyc-ch5 ${LLVM_MLIR_DIR}/test/Examples/Toy/Ch5/affine-lowering.mlir -emit=mlir

echo "=== Without Opitmization ============="
${LLVM_BIN_DIR}/toyc-ch5 ${LLVM_MLIR_DIR}/test/Examples/Toy/Ch5/affine-lowering.mlir -emit=mlir-affine

echo "=== With Optimization ================"
${LLVM_BIN_DIR}/toyc-ch5 ${LLVM_MLIR_DIR}/test/Examples/Toy/Ch5/affine-lowering.mlir -emit=mlir-affine -opt
