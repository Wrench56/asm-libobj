%include %strcat(%substr(__FILE__, 0, %strlen(__FILE__) - %strlen("objmesh.inc")), "cdef.inc")

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
    .index_count        uint32
    .index_offset       uint32
    .line_count         uint32
    .line_offset        uint32
endstruc

struc ObjObject
    .name               resb MAX_NAME_LENGTH
    .group_count        uint32
    .group_offset       uint32
endstruc

struc ObjMesh
    .vertex_count       uint64
    .texture_count      uint64
    .normal_count       uint64
    .index_count        uint64
    .line_count         uint64
    .object_count       uint64
    .group_count        uint64
    .material_count     uint64
    .vertices           ptr
    .textures           ptr
    .normals            ptr
    .indices            ptr
    .lines              ptr
    .objects            ptr
    .groups             ptr
    .materials          ptr
endstruc

