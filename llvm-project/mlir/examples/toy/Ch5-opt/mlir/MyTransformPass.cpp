#include "toy/Passes.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/raw_ostream.h"

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Pass/Pass.h"
#include "mlir/IR/BuiltinDialect.h"
#include "mlir/IR/BuiltinAttributes.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

#include <set>

using namespace mlir;

namespace {
struct ConstantPlusOne : public OpRewritePattern<arith::ConstantOp> {
  using OpRewritePattern<arith::ConstantOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(arith::ConstantOp op,
      PatternRewriter &rewriter) const final {
    Location loc = op.getLoc();
    Attribute oldValue = op.getValueAttr();
    llvm::errs() << "val" << *op << "\n";
    if (auto floatAttr = dyn_cast<FloatAttr>(oldValue)) {
      APFloat f = floatAttr.getValue();
      FloatAttr plusOne = rewriter.getF64FloatAttr(f.convertToDouble() + 1.0);
      Value plusOneOp = rewriter.create<arith::ConstantOp>(loc, plusOne);
      rewriter.replaceOp(op, plusOneOp);
      return success();
    }
    return rewriter.notifyMatchFailure(loc, "unhandled constant");
  }
};
} // namespace

namespace {
struct MyTransformPass : 
    public mlir::PassWrapper<MyTransformPass, OperationPass<>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(MyTransformPass)
  
  void runOnOperation() override {
    Operation *op = getOperation();
    llvm::errs() << "Operation: " << *op << "\n";
    RewritePatternSet patterns(&getContext());
    ConversionTarget target(getContext());
    
    target.addLegalDialect<arith::ArithDialect>();

    patterns.add<ConstantPlusOne>(&getContext());
    // MLIR 18.0.0 features
    // GreedyRewriteConfig config;
    // config.strictMode = GreedyRewriteStrictness::ExistingOps;
    if (failed(applyPartialConversion(getOperation(), target,
                                      std::move(patterns)))) {
      signalPassFailure();
    }
    return;
  }
};
} // namespace

/// Create a My Transformation Pass
std::unique_ptr<mlir::Pass> mlir::createMyTransformPass() {
  return std::make_unique<MyTransformPass>();
}
