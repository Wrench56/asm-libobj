; ========================================= ;
;                                           ;
;   Name     LIBOBJ                         ;
;   Author   Mark Devenyi                   ;
;   License  MIT                            ;
;   Arch     x64 (only)                     ;
;   Libs     libc, UCRT.dll                 ;
;                                           ;
;  A library for parsing 3D .obj files.     ;
;  This library should work well both on    ;
;  Windows and *nix. On any *nix, make sure ;
;  You have a valid libc and the required   ;
;  Tools needed to build this library.      ;
;                                           ;
; ========================================= ;


; ================[ EXTERN ]=============== ;
extern fopen
extern fclose
extern malloc
extern fgets
extern realloc
extern sscanf

; ===============[ INCLUDES ]============== ;
%include "includes/macros.inc"

; =================[ TEXT ]================ ;
section .text

; ========================================= ;
;                                           ;
;   Function: parse_obj_model               ;
;   Returns : *ObjModel                     ;
;   Args:                                   ;
;    > RDI - *char[] filename               ;
;                                           ;
; ----------------------------------------- ;
;                                           ;
;  This function parses a .obj file and     ;
;  returns a pointer to an ObjModel struct  ;
;                                           ;
; ========================================= ;
global parse_obj_model
parse_obj_model:
    push            rbx
    push            r12
    push            r13
    push            r14
    push            r15

    prolog          0

    epilog          0

    pop             r15
    pop             r14
    pop             r13
    pop             r12
    pop             rbx

    ret

