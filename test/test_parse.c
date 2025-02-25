#include <stdio.h>

extern void* parse_obj_model(const char* filename);

int main() {
    printf("===>  test_parse.c\n");
    parse_obj_model("examples/test.obj");
    printf("      Test done\n");

    return 0;
}

