#!/bin/bash

LLVM_BIN_DIR=../llvm-project/build/bin
LLVM_MLIR_DIR=../llvm-project/mlir

DUMP_FILE=tmp_codegen.mlir


parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
# pushd $parent_path

cd $parent_path

echo "=== Without My Pass ============="
${LLVM_BIN_DIR}/toyc-ch5 ${LLVM_MLIR_DIR}/test/Examples/Toy/Ch5/affine-lowering.mlir -emit=mlir-affine -opt

echo "=== With My Pass ================"
${LLVM_BIN_DIR}/toyc-ch5-opt ${LLVM_MLIR_DIR}/test/Examples/Toy/Ch5/affine-lowering.mlir -emit=mlir-affine -opt


# popd
