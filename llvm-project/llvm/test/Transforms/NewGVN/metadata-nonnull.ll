; RUN: opt %s -passes=newgvn -S | FileCheck %s
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define ptr @test1(ptr %v0, ptr %v1) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  top:
; CHECK-NEXT:    [[V2:%.*]] = load ptr, ptr [[V0:%[a-z0-9]+]], align 8, !nonnull !0
; CHECK-NEXT:    store ptr [[V2]], ptr [[V1:%.*]]
; CHECK-NEXT:    ret ptr [[V2]]
;
top:
  %v2 = load ptr, ptr %v0, !nonnull !0
  store ptr %v2, ptr %v1
  %v3 = load ptr, ptr %v1
  ret ptr %v3
}

; FIXME: could propagate nonnull to first load?
define ptr @test2(ptr %v0, ptr %v1) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:  top:
; CHECK-NEXT:    [[V2:%.*]] = load ptr, ptr [[V0:%[a-z0-9]+]]
; CHECK-NOT:     !nonnull
; CHECK-NEXT:    store ptr [[V2]], ptr [[V1:%.*]]
; CHECK-NEXT:    ret ptr [[V2]]
;
top:
  %v2 = load ptr, ptr %v0
  store ptr %v2, ptr %v1
  %v3 = load ptr, ptr %v1, !nonnull !0
  ret ptr %v3
}

declare void @use1(ptr %a) readonly

define ptr @test3(ptr %v0) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:  top:
; CHECK-NEXT:    [[V1:%.*]] = load ptr, ptr [[V0:%[a-z0-9]+]]
; CHECK-NOT:     !nonnull
; CHECK-NEXT:    call void @use1(ptr [[V1]])
; CHECK-NEXT:    br i1 undef, label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    ret ptr [[V1]]
; CHECK:       bb2:
; CHECK-NEXT:    ret ptr [[V1]]
;
top:
  %v1 = load ptr, ptr %v0
  call void @use1(ptr %v1)
  br i1 undef, label %bb1, label %bb2

bb1:
  %v2 = load ptr, ptr %v0, !nonnull !0
  ret ptr %v2

bb2:
  %v3 = load ptr, ptr %v0
  ret ptr %v3
}

define ptr @test4(ptr %v0) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:  top:
; CHECK-NEXT:    [[V1:%.*]] = load ptr, ptr [[V0:%[a-z0-9]+]]
; CHECK-NOT:     !nonnull
; CHECK-NEXT:    call void @use1(ptr [[V1]])
; CHECK-NEXT:    br i1 undef, label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    ret ptr [[V1]]
; CHECK:       bb2:
; CHECK-NEXT:    ret ptr [[V1]]
;
top:
  %v1 = load ptr, ptr %v0
  call void @use1(ptr %v1)
  br i1 undef, label %bb1, label %bb2

bb1:
  %v2 = load ptr, ptr %v0
  ret ptr %v2

bb2:
  %v3 = load ptr, ptr %v0, !nonnull !0
  ret ptr %v3
}

define ptr @test5(ptr %v0) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:  top:
; CHECK-NEXT:    [[V1:%.*]] = load ptr, ptr [[V0:%[a-z0-9]+]], align 8, !nonnull !0
; CHECK-NEXT:    call void @use1(ptr [[V1]])
; CHECK-NEXT:    br i1 undef, label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    ret ptr [[V1]]
; CHECK:       bb2:
; CHECK-NEXT:    ret ptr [[V1]]
;
top:
  %v1 = load ptr, ptr %v0, !nonnull !0
  call void @use1(ptr %v1)
  br i1 undef, label %bb1, label %bb2

bb1:
  %v2 = load ptr, ptr %v0
  ret ptr %v2

bb2:
  %v3 = load ptr, ptr %v0
  ret ptr %v3
}

define ptr @test6(ptr %v0, ptr %v1) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:  top:
; CHECK-NEXT:    br i1 undef, label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[V2:%.*]] = load ptr, ptr [[V0:%[a-z0-9]+]], align 8, !nonnull !0
; CHECK-NEXT:    store ptr [[V2]], ptr [[V1:%.*]]
; CHECK-NEXT:    ret ptr [[V2]]
; CHECK:       bb2:
; CHECK-NEXT:    [[V4:%.*]] = load ptr, ptr [[V0]]
; CHECK-NOT:     !nonnull
; CHECK-NEXT:    store ptr [[V4]], ptr [[V1]]
; CHECK-NOT:     !nonnull
; CHECK-NEXT:    ret ptr [[V4]]
;
top:
  br i1 undef, label %bb1, label %bb2

bb1:
  %v2 = load ptr, ptr %v0, !nonnull !0
  store ptr %v2, ptr %v1
  %v3 = load ptr, ptr %v1
  ret ptr %v3

bb2:
  %v4 = load ptr, ptr %v0
  store ptr %v4, ptr %v1
  %v5 = load ptr, ptr %v1, !nonnull !0
  ret ptr %v5
}

declare void @use2(ptr %a)

define ptr @test7(ptr %v0) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:  top:
; CHECK-NEXT:    [[V1:%.*]] = load ptr, ptr [[V0:%[a-z0-9]+]], align 8, !nonnull !0
; CHECK-NEXT:    call void @use2(ptr [[V1]])
; CHECK-NEXT:    br i1 undef, label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[V2:%.*]] = load ptr, ptr [[V0]]
; CHECK-NOT:     !nonnull
; CHECK-NEXT:    ret ptr [[V2]]
; CHECK:       bb2:
; CHECK-NEXT:    [[V3:%.*]] = load ptr, ptr [[V0]]
; CHECK-NOT:     !nonnull
; CHECK-NEXT:    ret ptr [[V3]]
;
top:
  %v1 = load ptr, ptr %v0, !nonnull !0
  call void @use2(ptr %v1)
  br i1 undef, label %bb1, label %bb2

bb1:
  %v2 = load ptr, ptr %v0
  ret ptr %v2

bb2:
  %v3 = load ptr, ptr %v0
  ret ptr %v3
}

!0 = !{}