#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

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

int main(void) {
    printf("=====>  test_raw_obj.c\n");
    struct RawObjMesh* mesh = parse_raw_obj("samples/cube.obj");
    if (mesh == NULL) {
        printf("[FAIL]  Test failed\n");
    } else {
        printf("[    ]  Vertex count....%" PRIu64 "\n", mesh->vertex_count);
        printf("[    ]  Normal count....%" PRIu64 "\n", mesh->normal_count);
        printf("[    ]  Texture count...%" PRIu64 "\n", mesh->texture_count);
        printf("[    ]  Index count.....%" PRIu64 "\n", mesh->index_count);
        free_raw_obj(mesh);
        mesh = NULL;

        printf("[ OK ]  Test done\n");
    }

    return 0;
}
