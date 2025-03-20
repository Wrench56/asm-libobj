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
SYSV extern void free_obj(struct ObjMesh* mesh);

int main(void) {
    printf("=====>  test_parse.c\n");
    struct ObjMesh* mesh = parse_obj_model("samples/cube.obj");
    if (mesh == NULL) {
        printf("[FAIL]  Test failed\n");
    } else {
        printf("[    ]  Vertex count....%" PRIu64 "\n", mesh->vertex_count);
        printf("[    ]  Normal count....%" PRIu64 "\n", mesh->normal_count);
        printf("[    ]  Texture count...%" PRIu64 "\n", mesh->texture_count);
        printf("[    ]  Face count......%" PRIu64 "\n", mesh->face_count);
        free_obj(mesh);
        mesh = NULL;

        printf("[ OK ]  Test done\n");
    }

    return 0;
}
