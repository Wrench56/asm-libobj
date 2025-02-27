%include "includes/cdef.inc"

%define MAX_NAME_LENGTH 64

struc ObjFace
    .position           uint32
    .texture            uint32
    .normal             uint32
    .__padding__        uint32
endstruc

struc ObjLineSegment
    .point1             uint32
    .point2             uint32
endstruc

struc ObjGroup
    .name               resb MAX_NAME_LENGTH
    .face_count         uint32
    .face_offset        uint32
    .line_count         uint32
    .line_offset        uint32
endstruc

struc ObjObject
    .name               resb MAX_NAME_LENGTH
    .group_count        uint32
    .group_offset       uint32
endstruc

struc ObjMesh
    .vertex_count       uint32
    .texture_count      uint32
    .normal_count       uint32
    .face_count         uint32
    .line_count         uint32
    .object_count       uint32
    .group_count        uint32
    .material_count     uint32
    .vertices           ptr
    .textures           ptr
    .normals            ptr
    .faces              ptr
    .lines              ptr
    .objects            ptr
    .groups             ptr
    .materials          ptr
endstruc

