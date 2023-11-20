#include "toy/Passes.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/raw_ostream.h"

#include "mlir/Dialect/Affine/IR/AffineOps.h"
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
      PatternRewriter &rewriter) const override {
    return success();
  }
};

/// Make all the constants as 1337.
/// refer to mlir/lib/Dialect/Shape/Transforms/RemoveShapeConstraints.cpp
class LeetOnly : public OpRewritePattern<arith::ConstantOp> {
public:
  using OpRewritePattern<arith::ConstantOp>::OpRewritePattern;
  
  LogicalResult matchAndRewrite(arith::ConstantOp op,
      PatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    Attribute attr = op.getValueAttr();
    if (auto floatAttr = dyn_cast<FloatAttr>(attr)) {
      double f64 = floatAttr.getValue().convertToDouble();
      if (f64 == 1337.) {
        return success();
      }
      llvm::errs() << "processing... " << f64 << " at " << loc << "\n";
      FloatAttr leet = rewriter.getF64FloatAttr(1337.);
      Value leetOp = rewriter.create<arith::ConstantOp>(loc, leet);
      rewriter.replaceOp(op, leetOp);
    }
    return success();
  }
};

class LeetOnly2 : public OpRewritePattern<arith::ConstantOp> {
public:
  using OpRewritePattern<arith::ConstantOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(arith::ConstantOp op, 
      PatternRewriter &rewriter) const override {
    static int modified = 0;
    if (modified >= 1)
      return failure();

    Attribute attr = op.getValueAttr();
    auto floatAttr = dyn_cast_or_null<FloatAttr>(attr);
    if (!floatAttr)
      return success();
    double f64 = floatAttr.getValue().convertToDouble();
    if (f64 == 1337.)
      return failure();
    FloatAttr leet = rewriter.getF64FloatAttr(1337.);
    Value leetOp = rewriter.create<arith::ConstantOp>(op.getLoc(), leet);
    rewriter.replaceOp(op, leetOp);
    modified += 1;
    return success();
  }
};

class StoreOpt : public OpRewritePattern<AffineStoreOp> {
public:
  using OpRewritePattern<AffineStoreOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(AffineStoreOp op,
      PatternRewriter &rewriter) const override {
    llvm::errs() << *op << "\n";
    // llvm::errs() << op.getValue() << "\n";
    for (unsigned int i = 0; i < op->getNumOperands(); ++i) {
      llvm::errs() << i << ": " << op->getOperand(i) << "\n";
    }

    Value lhs = op->getOperand(0);
    Operation* lhsOp = lhs.getDefiningOp();
    if (auto constantOp = dyn_cast<arith::ConstantOp>(lhsOp)) {
      Attribute attr = constantOp.getValueAttr();
      auto floatAttr = dyn_cast_or_null<FloatAttr>(attr);
      if (!floatAttr)
        return failure();

      double f64 = floatAttr.getValue().convertToDouble();
      if (f64 > 1337.)
        return failure();
      
      FloatAttr leet = rewriter.getF64FloatAttr(f64 + 1337.);
      Value leetOp = rewriter.create<arith::ConstantOp>(
          constantOp.getLoc(), leet);
      rewriter.replaceOp(constantOp, leetOp);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct MyTransformPass : 
    public mlir::PassWrapper<MyTransformPass, OperationPass<>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(MyTransformPass)
  
  void runOnOperation() override {
    Operation* op = getOperation();
    RewritePatternSet patterns(&getContext());
    patterns.add<StoreOpt>(patterns.getContext());
    // MLIR 18.0.0 features
    // GreedyRewriteConfig config;
    // config.strictMode = GreedyRewriteStrictness::ExistingOps;
    (void)applyPatternsAndFoldGreedily(op, std::move(patterns));
  }
};
} // namespace


/// Create a My Transformation Pass
std::unique_ptr<mlir::Pass> mlir::createMyTransformPass() {
  return std::make_unique<MyTransformPass>();
}
