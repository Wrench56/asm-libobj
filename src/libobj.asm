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
extern fgets
extern malloc
extern realloc

; ===============[ INCLUDES ]============== ;
%include "includes/cdef.inc"
%include "includes/macros.inc"
%include "includes/objmesh.inc"

; ================[ LOCALS ]=============== ;
deflocal file_handle, 8
deflocal obj_model,   8
deflocal line_buffer, 256

; ================[ CONSTS ]=============== ;
%define GROWTH_EXP       2

%define INITIAL_VERTICES 1024
%define INITIAL_TEXTURES 1024
%define INITIAL_NORMALS  1024
%define INITIAL_FACES    1024
%define INITIAL_OBJECTS  8
%define INITIAL_GROUPS   32

%define FLOAT_SIZE       4

; =================[ DATA ]================ ;
section .data
    MODE_READ       db "r", 0

; =================[ TEXT ]================ ;
section .text

; ========================================= ;
;                                           ;
;   Function: parse_obj_model               ;
;   Returns : ObjModel* mesh                ;
;   Args:                                   ;
;    > RDI - char* filename[]               ;
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
    push            rbp

    prolog          6, 16 + 256

    ; Open .obj file
    mov             arg(2), MODE_READ
    call            fopen
    test            rax, rax
    jz              .exit_no_file_cleanup
    mov             [file_handle], rax

    ; Allocate ObjMesh struct
    mov             rdi, sizeof(ObjMesh)
    call            malloc
    test            rax, rax
    jz              .exit_parser_loop
    mov             [obj_model], rax

    ; Zero out ObjMesh
    cld
    mov             rdi, rax
    mov             rcx, sizeof(ObjMesh) / 8
    xor             rax, rax
    rep             stosq

    mov             rbx, [obj_model]

    ; Vertices
    mov             arg(1), INITIAL_VERTICES * 3 * FLOAT_SIZE
    call            malloc
    mov             [rbx + ObjMesh.vertices], rax

    ; Textures
    mov             arg(1), INITIAL_TEXTURES * 3 * FLOAT_SIZE
    call            malloc
    mov             [rbx + ObjMesh.textures], rax

    ; Normals
    mov             arg(1), INITIAL_NORMALS * 3 * FLOAT_SIZE
    call            malloc
    mov             [rbx + ObjMesh.normals], rax

    ; Faces
    mov             arg(1), INITIAL_FACES * sizeof(ObjFace)
    call            malloc
    mov             [rbx + ObjMesh.faces], rax

    ; Objects
    mov             arg(1), INITIAL_OBJECTS * sizeof(ObjObject)
    call            malloc
    mov             [rbx + ObjMesh.objects], rax

    ; Groups
    mov             arg(1), INITIAL_GROUPS * sizeof(ObjGroup)
    call            malloc
    mov             [rbx + ObjMesh.groups], rax

.parser_loop:
    lea             arg(1), [line_buffer]
    mov             arg(2), 256
    mov             arg(3), [file_handle]
    call            fgets
    test            rax, rax
    jz              .exit_parser_loop

    jmp             .parser_loop

.exit_parser_loop:
    ; Close .obj file
    mov             arg(1), [file_handle]
    call            fclose

.exit_no_file_cleanup:

    mov             rax, rbx

    epilog

    pop             rbp
    pop             r15
    pop             r14
    pop             r13
    pop             r12
    pop             rbx

    ret


; ========================================= ;
;                                           ;
;   Function: grow_array                    ;
;   Returns : void* new_ptr                 ;
;   Args:                                   ;
;    > RDI - void* arr                      ;
;    > RSI - uint32 count                   ;
;    > RDX - size_t elem_size               ;
;                                           ;
; ----------------------------------------- ;
;                                           ;
;  This function manages the array growth   ;
;  of vertices, faces, texture coords, etc. ;
;                                           ;
; ========================================= ;
grow_array:
    prolog          0, 0

    ; Growth logic: (elem_size * count * (2^GROWTH_EXP))
    shl             rsi, GROWTH_EXP
    imul            rsi, rdx

    ; TODO: Optimize for System V ABI
    mov             arg(1), rdi
    mov             arg(2), rsi
    call            realloc

    epilog
    ret

