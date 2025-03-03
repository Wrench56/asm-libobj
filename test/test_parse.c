#include <stdio.h>
#include <stdint.h>

struct ObjMesh {
    uint64_t vertex_count;
    uint64_t normal_count;
    uint64_t texture_count;
    uint64_t face_count;
    uint64_t line_count;
    uint64_t group_count;
    uint64_t object_count;
    uint64_t material_count;
    float* vertices;
    float* normals;
    float* textures;
    void* faces;
    void* lines;
    void* groups;
    void* objects;
    void* materials;
};

extern struct ObjMesh* parse_obj_model(const char* filename);

int main() {
    printf("=====>  test_parse.c\n");
    struct ObjMesh* retval = parse_obj_model("samples/cube.obj");
    if (retval == NULL) {
        printf("[FAIL]  Test failed\n");
    } else {
        printf("[    ]  Vertex count....%lu\n", retval->vertex_count);
        printf("[    ]  Normal count....%lu\n", retval->normal_count);
        printf("[    ]  Texture count...%lu\n", retval->texture_count);
        printf("[    ]  Face count......%lu\n", retval->face_count);
        printf("[ OK ]  Test done\n");
    }

    return 0;
}

