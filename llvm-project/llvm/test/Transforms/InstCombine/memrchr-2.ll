; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=instcombine -S | FileCheck %s
;
; Verify that memrchr calls with an out of bounds size are not folded to
; null (they might be intercepted by sanitizers).

declare ptr @memrchr(ptr, i32, i64)

@ax = external global [0 x i8]
@ax1 = external global [1 x i8]
@a12345 = constant [5 x i8] c"\01\02\03\04\05"


; Do not fold memrchr(a12345, C, UINT32_MAX + 1LU) to null or to a12345
; as might happen if the size were to be truncated to int32_t.

define ptr @call_memrchr_a12345_c_ui32max_p1(i32 %C) {
; CHECK-LABEL: @call_memrchr_a12345_c_ui32max_p1(
; CHECK-NEXT:    [[RET:%.*]] = call ptr @memrchr(ptr noundef nonnull dereferenceable(4294967296) @a12345, i32 [[C:%.*]], i64 4294967296)
; CHECK-NEXT:    ret ptr [[RET]]
;

  %ret = call ptr @memrchr(ptr @a12345, i32 %C, i64 4294967296)
  ret ptr %ret
}


; Do not fold memrchr(ax1, C, UINT32_MAX + 2LU) to null or to *ax1 == 1.

define ptr @call_memrchr_ax1_c_ui32max_p2(i32 %C) {
; CHECK-LABEL: @call_memrchr_ax1_c_ui32max_p2(
; CHECK-NEXT:    [[RET:%.*]] = call ptr @memrchr(ptr noundef nonnull dereferenceable(4294967297) @ax1, i32 [[C:%.*]], i64 4294967297)
; CHECK-NEXT:    ret ptr [[RET]]
;

  %ret = call ptr @memrchr(ptr @ax1, i32 %C, i64 4294967297)
  ret ptr %ret
}


; Do not fold memrchr(ax, C, UINT32_MAX + 2LU) to *ax == 1.

define ptr @call_memrchr_ax_c_ui32max_p2(i32 %C) {
; CHECK-LABEL: @call_memrchr_ax_c_ui32max_p2(
; CHECK-NEXT:    [[RET:%.*]] = call ptr @memrchr(ptr noundef nonnull dereferenceable(4294967297) @ax, i32 [[C:%.*]], i64 4294967297)
; CHECK-NEXT:    ret ptr [[RET]]
;

  %ret = call ptr @memrchr(ptr @ax, i32 %C, i64 4294967297)
  ret ptr %ret
}


; Do not fold memrchr(a12345, C, 6) to null.

define ptr @call_memrchr_a12345_c_6(i32 %C) {
; CHECK-LABEL: @call_memrchr_a12345_c_6(
; CHECK-NEXT:    [[RET:%.*]] = call ptr @memrchr(ptr noundef nonnull dereferenceable(6) @a12345, i32 [[C:%.*]], i64 6)
; CHECK-NEXT:    ret ptr [[RET]]
;

  %ret = call ptr @memrchr(ptr @a12345, i32 %C, i64 6)
  ret ptr %ret
}


; Do not fold memrchr(a12345, C, SIZE_MAX) to null.

define ptr @call_memrchr_a12345_c_szmax(i32 %C) {
; CHECK-LABEL: @call_memrchr_a12345_c_szmax(
; CHECK-NEXT:    [[RET:%.*]] = call ptr @memrchr(ptr noundef nonnull dereferenceable(18446744073709551615) @a12345, i32 [[C:%.*]], i64 -1)
; CHECK-NEXT:    ret ptr [[RET]]
;

  %ret = call ptr @memrchr(ptr @a12345, i32 %C, i64 18446744073709551615)
  ret ptr %ret
}