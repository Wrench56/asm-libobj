#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

#define SYSV __attribute__((sysv_abi))

struct ObjMesh {
    uint64_t vertex_count;
    uint64_t texture_count;
    uint64_t normal_count;
    uint64_t face_count;
    uint64_t line_count;
    uint64_t group_count;
    uint64_t object_count;
    uint64_t material_count;
    float* vertices;
    float* textures;
    float* normals;
    unsigned int* faces;
    void* lines;
    void* objects;
    void* groups;
    void* materials;
};

SYSV extern struct ObjMesh* parse_obj_model(const char* filename);

int main(void) {
    printf("=====>  test_parse.c\n");
    struct ObjMesh* retval = parse_obj_model("samples/cube.obj");
    if (retval == NULL) {
        printf("[FAIL]  Test failed\n");
    } else {
        printf("[    ]  Vertex count....%" PRIu64 "\n", retval->vertex_count);
        printf("[    ]  Normal count....%" PRIu64 "\n", retval->normal_count);
        printf("[    ]  Texture count...%" PRIu64 "\n", retval->texture_count);
        printf("[    ]  Face count......%" PRIu64 "\n", retval->face_count);
        printf("[ OK ]  Test done\n");
    }

    return 0;
}
