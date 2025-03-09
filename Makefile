# Directories
BUILD_DIR := ./build
SRC_DIR := ./src

# Default Platform Detection
ifeq ($(OS),Windows_NT)
    PLATFORM := win
else
    PLATFORM := nix
endif

# Platform-Specific Settings
ifeq ($(PLATFORM),win)
    EXE := $(BUILD_DIR)/oxnag.exe
    ASM := nasm
    ASM_FLAGS := -f win64 -g -DTARGET_OS=OS_WINDOWS
else
    EXE := $(BUILD_DIR)/oxnag
    ASM := nasm
    ASM_FLAGS := -f elf64 -g -DTARGET_OS=OS_LINUX
endif

# Source and Object Files
COMMON_SRCS := $(wildcard $(SRC_DIR)/*.asm) $(wildcard $(COMMON_DIR)/*.asm) $(wildcard $(COMMON_DIR)/**/*.asm)
PLATFORM_SRCS += $(wildcard $(PLATFORM_DIR)/*.asm)
ifeq ($(PLATFORM),nix)
    PLATFORM_SRCS += $(wildcard $(PLATFORM_DIR)/posix/*.asm)
endif
UTIL_SRCS := $(wildcard $(SRC_DIR)/utils/*.asm)
ALL_SRCS := $(COMMON_SRCS) $(PLATFORM_SRCS) $(UTIL_SRCS)
ALL_OBJS := $(patsubst %.asm, $(BUILD_DIR)/%.o, $(notdir $(ALL_SRCS)))

# Targets
.PHONY: all banner compile test clean help

# Default Target
all: banner compile test

# Banner Target
banner:
	@echo "==============[ LIBOBJ* ]=============="
	@echo "Platform: $(PLATFORM)"
	@if [ -d "$(BUILD_DIR)" ]; then \
		printf "Build Directory: \033[32mExists\033[0m\n"; \
	else \
		printf "Build Directory: \033[31mMissing\033[0m\n"; \
	fi
	@if command -v $(ASM) > /dev/null 2>&1; then \
		echo "NASM Version: $$( $(ASM) -v | sed 's/NASM version \([0-9]*\.[0-9]*\.[0-9]*\).*/\1/' | head -n 1 )"; \
	else \
		printf "NASM Version: \033[31mMissing\033[0m\n"; \
	fi
	@echo ""

# Compile All Sources
compile:
	@echo "=============[ COMPILING ]============="
	@for SRC in $(ALL_SRCS); do \
		OBJ=$(BUILD_DIR)/$$(basename $${SRC%.asm}.o); \
		$(ASM) $(ASM_FLAGS) $$SRC -o $$OBJ; \
		echo "Compiled: $$SRC"; \
	done

# Compile tests
test: compile
	@printf "\n==============[ TESTING ]==============\n"
	@clang -Wall -Wextra -Wpedantic -fsanitize=address,undefined -O2 -no-pie -g -lc test/test_parse.c build/libobj.o -o build/test_parse
	@printf "Running tests...\n"
	@exec ./build/test_parse

# Clean Build Directory
clean:
	@echo "Cleaning build directory..."
	@rm -f $(BUILD_DIR)/*

# Help Message
help:
	@: $(info $(HELP_STRING))

define HELP_STRING
usage: make <target>
targets:
 * banner               Show project banner
 * compile              Compile all sources (current platform)
 * link                 Link all object files (current platform)
 * clean                Clean the build directory
 * help                 Show this menu
endef

