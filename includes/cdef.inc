; ================================
; C-Like Type Definitions in NASM
; ================================

%define NULL 0

%define uint64  resq 1
%define int64   resq 1
%define ptr     resq 1
%define uint32  resd 1
%define int32   resd 1
%define float32 resd 1


%define sizeof(struc_type_name) (struc_type_name%+_size)

