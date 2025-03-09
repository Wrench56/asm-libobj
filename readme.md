# ASM libobj

A NASM library for parsing 3D Wavefront (`.obj`) files.

## Features

- [X] Basic file handling
- [X] Error handling (returns `NULL` on failure)
- [X] Dynamic memory allocation and growth
- [X] Vertex position parsing (`v`)
- [X] Vertex texture coordinate parsing (`vt`)
- [X] Vertex normal parsing (`vn`)
- [X] Face parsing (`f`)
- [X] Face parsing with missing indices (`f 1// 2// 3//`)
- [ ] Face parsing for quads (`f 1// 2// 3// 4//`)
- [ ] Line parsing (`l`)
- [ ] Smooth shading parsing (`s`)
- [ ] Group parsing (`g`)
- [ ] Object parsing (`o`)
- [ ] Material parsing (`usemtl` / `mtllib`)
- [ ] PBR materials extension

### Features That Won't Be Added

Support for NURBS (Non-Uniform Rational B-Splines) features will not be implemented. This includes `cstype`, `deg`, `surf`, `parm`, `trim`, `hole`, `scrv`, `sp`, and `end`. These features are rarely used in modern `.obj` loaders and are neither pragmatic for GPUs nor commonly supported in 3D modeling software.

---

## Usage

### Simple C Example

```c
#include <stdio.h>
#include <stdint.h>

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

extern struct ObjMesh* parse_obj_model(const char* filename);

int main(void) {
    struct ObjMesh* mesh = parse_obj_model("path/to/obj");
    if (mesh == NULL) {
        printf("Error: Failed to load or parse .obj file!\n");
        return 1;
    }

    printf("Vertex count: %lu\n", mesh->vertex_count);
    return 0;
}

```

