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
extern free
extern strtof
extern strtoumax

; ===============[ INCLUDES ]============== ;
%include "includes/cdef.inc"
%include "includes/macros.inc"
%include "includes/objmesh.inc"

; ================[ LOCALS ]=============== ;
deflocal file_handle,  8
deflocal obj_model,    8
deflocal tmp_endptr,   8

deflocal vertex_cap,   8
deflocal normal_cap,   8
deflocal texture_cap,  8
deflocal index_cap,    8

deflocal line_buffer,  256

; ================[ CONSTS ]=============== ;
%define GROWTH_EXP       2

%define INITIAL_VERTICES 1024
%define INITIAL_TEXTURES 1024
%define INITIAL_NORMALS  1024
%define INITIAL_FACES    1024
%define INITIAL_OBJECTS  8
%define INITIAL_GROUPS   32

%define FLOAT_SIZE       4
%define UINT32_SIZE      4

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

    prolog          6, 56 + 256

    ; Open .obj file
%ifidn TARGET_OS, OS_WINDOWS
    mov             arg(1), rdi
%endif
    mov             arg(2), MODE_READ
    call            fopen
    test            rax, rax
    jz              .fopen_fail
    mov             [file_handle], rax

    ; Allocate ObjMesh struct
    mov             arg(1), sizeof(ObjMesh)
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
    mov             qword [vertex_cap], INITIAL_VERTICES

    ; Textures
    mov             arg(1), INITIAL_TEXTURES * 2 * FLOAT_SIZE
    call            malloc
    mov             [rbx + ObjMesh.textures], rax
    mov             qword [texture_cap], INITIAL_TEXTURES

    ; Normals
    mov             arg(1), INITIAL_NORMALS * 3 * FLOAT_SIZE
    call            malloc
    mov             [rbx + ObjMesh.normals], rax
    mov             qword [normal_cap], INITIAL_NORMALS

    ; Indices
    mov             arg(1), INITIAL_FACES * 3 * 3 * UINT32_SIZE
    call            malloc
    mov             [rbx + ObjMesh.indices], rax
    mov             qword [index_cap], INITIAL_FACES

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

    ; Check for [v]ertex
    cmp             word [line_buffer], "v "
    jne             .not_vertex

    ; Check if array growth is needed
    mov             r15, [rbx + ObjMesh.vertex_count]
    cmp             r15, [vertex_cap]
    js              .vertex_parse

    ; Grow vertex array
    mov             rdi, [rbx + ObjMesh.vertices]
    mov             rsi, r15
    mov             rdx, 3 * FLOAT_SIZE
    call            grow_array
    mov             [rbx + ObjMesh.vertices], rax

    ; Update capacity
    shl             qword [vertex_cap], GROWTH_EXP

.vertex_parse:

    ; Pointer to next empty element in vertices
    ; Equivalent to mesh->vertices[mesh->vertex_count * 3]
    ; 1. Multiply vertex_count by 3
    lea             r15, [2 * r15 + r15]
    ; 2. Multiply by element size (FLOAT_SIZE)
    shl             r15, 2
    ; 3. Get start address of vertices[]
    mov             r14, [rbx + ObjMesh.vertices]
    ; 4. Get address of next element
    add             r15, r14

    ; 1st coord
    lea             arg(1), [line_buffer + 2]
    lea             arg(2), [tmp_endptr]
    call            strtof
    movss           [r15], xmm0

    ; 2nd coord
    mov             arg(1), [tmp_endptr]
    lea             arg(2), [tmp_endptr]
    call            strtof
    movss           [r15 + FLOAT_SIZE], xmm0

    ; 3rd coord
    mov             arg(1), [tmp_endptr]
    xor             arg(2), arg(2)
    call            strtof
    movss           [r15 + 2 * FLOAT_SIZE], xmm0

    ; Increase vertex_count
    inc             dword [rbx + ObjMesh.vertex_count]
    jmp             .parser_loop

.not_vertex:
    ; Check for [vn]ormals
    ; Similar to vertex position parsing
    ; Check vertex position parsing for additional comments
    cmp             word [line_buffer], "vn"
    jne             .not_normal

    mov             r15, [rbx + ObjMesh.normal_count]
    cmp             r15, [normal_cap]
    js              .normal_parse

    mov             rdi, [rbx + ObjMesh.normals]
    mov             rsi, r15
    mov             rdx, 3 * FLOAT_SIZE
    call            grow_array
    mov             [rbx + ObjMesh.normals], rax

    shl             qword [normal_cap], GROWTH_EXP

.normal_parse:

    lea             r15, [2 * r15 + r15]
    shl             r15, 2
    mov             r14, [rbx + ObjMesh.normals]
    add             r15, r14

    lea             arg(1), [line_buffer + 3]
    lea             arg(2), [tmp_endptr]
    call            strtof
    movss           [r15], xmm0

    mov             arg(1), [tmp_endptr]
    lea             arg(2), [tmp_endptr]
    call            strtof
    movss           [r15 + FLOAT_SIZE], xmm0

    mov             arg(1), [tmp_endptr]
    xor             arg(2), arg(2)
    call            strtof
    movss           [r15 + 2 * FLOAT_SIZE], xmm0

    inc             dword [rbx + ObjMesh.normal_count]
    jmp             .parser_loop

.not_normal:
    ; Check for [vt]exture
    ; Similar to vertex position parsing
    ; Check vertex position parsing for additional comments
    cmp             word [line_buffer], "vt"
    jne             .not_texture

    mov             r15, [rbx + ObjMesh.texture_count]
    cmp             r15, [texture_cap]
    js              .texture_parse

    mov             rdi, [rbx + ObjMesh.textures]
    mov             rsi, r15
    mov             rdx, 2 * FLOAT_SIZE
    call            grow_array
    mov             [rbx + ObjMesh.textures], rax

    shl             qword [texture_cap], GROWTH_EXP

.texture_parse:
    shl             r15, 1 + 2
    mov             r14, [rbx + ObjMesh.textures]
    add             r15, r14

    lea             arg(1), [line_buffer + 3]
    lea             arg(2), [tmp_endptr]
    call            strtof
    movss           [r15], xmm0

    mov             arg(1), [tmp_endptr]
    xor             arg(2), arg(2)
    call            strtof
    movss           [r15 + FLOAT_SIZE], xmm0

    inc             dword [rbx + ObjMesh.texture_count]
    jmp             .parser_loop

.not_texture:
    ; Check for [f]ace
    cmp             word [line_buffer], "f "
    jne             .not_index

    mov             r15, [rbx + ObjMesh.index_count]
    cmp             r15, [index_cap]
    js              .index_parse_init

    mov             rdi, [rbx + ObjMesh.indices]
    mov             rsi, r15
    mov             rdx, 3 * 3 * UINT32_SIZE
    call            grow_array
    mov             [rbx + ObjMesh.indices], rax

    shl             qword [index_cap], GROWTH_EXP

.index_parse_init:
    lea             r15, [8 * r15 + r15]
    shl             r15, 2
    mov             r14, [rbx + ObjMesh.indices]
    add             r15, r14
    xor             r14, r14
    lea             rax, [line_buffer + 2]
    mov             [tmp_endptr], rax

._index_parse_v:
    mov             arg(1), [tmp_endptr]
    lea             arg(2), [tmp_endptr]
    mov             arg(3), 10
    call            strtoumax
    dec             eax
    mov             dword [r15], eax
    inc             qword [tmp_endptr]

    cmp             byte [tmp_endptr], "/"
    je              ._index_skip_parse_vt
._index_parse_vt:
    mov             arg(1), [tmp_endptr]
    lea             arg(2), [tmp_endptr]
    mov             arg(3), 10
    call            strtoumax
    dec             eax
    mov             dword [r15 + UINT32_SIZE], eax
    jmp             ._index_check_parse_vn
._index_skip_parse_vt:
    mov             dword [r15 + UINT32_SIZE], 0
._index_check_parse_vn:
    inc             qword [tmp_endptr]
    cmp             byte [tmp_endptr], "/"
    je              ._index_skip_parse_vn

._index_parse_vn:
    mov             arg(1), [tmp_endptr]
    lea             arg(2), [tmp_endptr]
    mov             arg(3), 10
    call            strtoumax
    dec             eax
    mov             dword [r15 + UINT32_SIZE * 2], eax
    jmp             ._index_check_reloop

._index_skip_parse_vn:
    mov             dword [r15 + UINT32_SIZE * 2], 0
._index_check_reloop:
    cmp             r14, 2
    je              ._index_parse_cleanup
    inc             qword [tmp_endptr]
    inc             r14
    add             r15, UINT32_SIZE * 3
    jmp             ._index_parse_v

._index_parse_cleanup:
    inc             dword [rbx + ObjMesh.index_count]
    jmp             .parser_loop
.not_index:
    jmp             .parser_loop

.exit_parser_loop:
    ; Close .obj file
    mov             arg(1), [file_handle]
    call            fclose

    ; Return ObjMesh struct
    mov             rax, rbx

.fopen_fail:
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
;   Function: free_obj                      ;
;   Returns : void                          ;
;   Args:                                   ;
;    > RDI - struct ObjMesh* mesh           ;
;                                           ;
; ----------------------------------------- ;
;                                           ;
;  This function frees the ObjMesh          ;
;  structure.                               ;
;                                           ;
; ========================================= ;
global free_obj
free_obj:
    push            rbx

    prolog          0, 0

    mov             rbx, rdi
    mov             arg(1), [rbx + ObjMesh.vertices]
    call            free

    mov             arg(1), [rbx + ObjMesh.textures]
    call            free

    mov             arg(1), [rbx + ObjMesh.normals]
    call            free

    mov             arg(1), [rbx + ObjMesh.indices]
    call            free

    mov             arg(1), [rbx + ObjMesh.objects]
    call            free

    mov             arg(1), [rbx + ObjMesh.groups]
    call            free

    mov             arg(1), rbx
    call            free

    epilog

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
;  of vertices, indices, texture coords,    ;
;  etc.                                     ;
;                                           ;
; ========================================= ;
grow_array:
    prolog          0, 0

    ; Growth logic: (elem_size * count * (2^GROWTH_EXP))
    shl             rsi, GROWTH_EXP
    imul            rsi, rdx

    ; Adjust register arguments for non-System V ABIs
%ifidn TARGET_OS, OS_WINDOWS
    mov             arg(1), rdi
    mov             arg(2), rsi
%endif
    call            realloc

    epilog
    ret

