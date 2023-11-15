#!/bin/bash

LLVM_BIN_DIR=../../llvm-project/build/bin
LLVM_MLIR_DIR=../../llvm-project/mlir

# emit without optimize
echo "=== See the toyfile"
cat ${LLVM_MLIR_DIR}/test/Examples/Toy/Ch4/codegen.toy


echo "=== Without Optimization ========================================================================"
${LLVM_BIN_DIR}/toyc-ch4 ${LLVM_MLIR_DIR}/test/Examples/Toy/Ch4/codegen.toy -emit=mlir


echo "=== With Optimization: just inlining ===================================================================================="
${LLVM_BIN_DIR}/toyc-ch4 ${LLVM_MLIR_DIR}/test/Examples/Toy/Ch3/codegen.toy -emit=mlir -opt -fno-inf


echo "=== With Optimization ===================================================================================="
${LLVM_BIN_DIR}/toyc-ch4 ${LLVM_MLIR_DIR}/test/Examples/Toy/Ch3/codegen.toy -emit=mlir -opt
