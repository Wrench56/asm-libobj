#include <stdio.h>

extern void* parse_obj_model(const char* filename);

int main() {
    printf("=====>  test_parse.c\n");
    void* retval = parse_obj_model("examples/test.obj");
    if (retval == NULL) {
        printf("[FAIL]  Test failed\n");
    } else {
        printf("[ OK ]  Test done\n");
    }

    return 0;
}

