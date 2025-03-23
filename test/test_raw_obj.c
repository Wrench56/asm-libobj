#include <stdio.h>
#include <inttypes.h>

#include "libobj.h"

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
