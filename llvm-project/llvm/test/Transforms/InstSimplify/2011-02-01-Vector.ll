; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=instsimplify -S | FileCheck %s

define <2 x i32> @sdiv(<2 x i32> %x) {
; CHECK-LABEL: @sdiv(
; CHECK-NEXT:    ret <2 x i32> [[X:%.*]]
;
  %div = sdiv <2 x i32> %x, <i32 1, i32 1>
  ret <2 x i32> %div
}