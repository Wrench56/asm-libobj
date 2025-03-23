#include <stdint.h>

#define SYSV __attribute__((sysv_abi))

struct RawObjMesh {
    uint64_t vertex_count;
    uint64_t texture_count;
    uint64_t normal_count;
    uint64_t index_count;
    uint64_t line_count;
    uint64_t group_count;
    uint64_t object_count;
    uint64_t material_count;
    float* vertices;
    float* textures;
    float* normals;
    unsigned int* indices;
    void* lines;
    void* objects;
    void* groups;
    void* materials;
};

SYSV extern struct RawObjMesh* parse_raw_obj(const char* filename);
SYSV extern void free_raw_obj(struct RawObjMesh* raw_mesh);

