; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -passes=slp-vectorizer < %s | FileCheck %s
target datalayout = "e-m:x-p:32:32-i64:64-f80:32-n8:16:32-a:0:32-S32"
target triple = "i686-pc-windows-msvc18.0.0"

define void @test1(ptr %a, ptr %b, ptr %c) #0 personality ptr @__CxxFrameHandler3 {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    invoke void @_CxxThrowException(ptr null, ptr null)
; CHECK-NEXT:    to label [[UNREACHABLE:%.*]] unwind label [[CATCH_DISPATCH:%.*]]
; CHECK:       catch.dispatch:
; CHECK-NEXT:    [[TMP0:%.*]] = catchswitch within none [label %catch] unwind to caller
; CHECK:       catch:
; CHECK-NEXT:    [[TMP1:%.*]] = catchpad within [[TMP0]] [ptr null, i32 64, ptr null]
; CHECK-NEXT:    [[TMP3:%.*]] = load <2 x double>, ptr [[A:%.*]], align 8
; CHECK-NEXT:    [[TMP5:%.*]] = load <2 x double>, ptr [[B:%.*]], align 8
; CHECK-NEXT:    [[TMP6:%.*]] = fmul <2 x double> [[TMP3]], [[TMP5]]
; CHECK-NEXT:    [[TMP7:%.*]] = call <2 x double> @llvm.floor.v2f64(<2 x double> [[TMP6]]) [ "funclet"(token [[TMP1]]) ]
; CHECK-NEXT:    store <2 x double> [[TMP7]], ptr [[C:%.*]], align 8
; CHECK-NEXT:    catchret from [[TMP1]] to label [[TRY_CONT:%.*]]
; CHECK:       try.cont:
; CHECK-NEXT:    ret void
; CHECK:       unreachable:
; CHECK-NEXT:    unreachable
;
entry:
  invoke void @_CxxThrowException(ptr null, ptr null)
  to label %unreachable unwind label %catch.dispatch

catch.dispatch:                                   ; preds = %entry
  %0 = catchswitch within none [label %catch] unwind to caller

catch:                                            ; preds = %catch.dispatch
  %1 = catchpad within %0 [ptr null, i32 64, ptr null]
  %i0 = load double, ptr %a, align 8
  %i1 = load double, ptr %b, align 8
  %mul = fmul double %i0, %i1
  %call = tail call double @floor(double %mul) #1 [ "funclet"(token %1) ]
  %arrayidx3 = getelementptr inbounds double, ptr %a, i64 1
  %i3 = load double, ptr %arrayidx3, align 8
  %arrayidx4 = getelementptr inbounds double, ptr %b, i64 1
  %i4 = load double, ptr %arrayidx4, align 8
  %mul5 = fmul double %i3, %i4
  %call5 = tail call double @floor(double %mul5) #1 [ "funclet"(token %1) ]
  store double %call, ptr %c, align 8
  %arrayidx5 = getelementptr inbounds double, ptr %c, i64 1
  store double %call5, ptr %arrayidx5, align 8
  catchret from %1 to label %try.cont

try.cont:                                         ; preds = %for.cond.cleanup
  ret void

unreachable:                                      ; preds = %entry
  unreachable
}

declare x86_stdcallcc void @_CxxThrowException(ptr, ptr)

declare i32 @__CxxFrameHandler3(...)

declare double @floor(double) #1

attributes #0 = { "target-features"="+sse2" }
attributes #1 = { nounwind readnone willreturn }