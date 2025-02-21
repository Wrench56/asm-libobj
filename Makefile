# Directories
BUILD_DIR := ./build
SRC_DIR := ./src

# Default Platform Detection (fallback)
ifeq ($(OS),Windows_NT)
    PLATFORM := win
else
    PLATFORM := nix
endif

# Override PLATFORM Based on Explicit Target
ifneq ($(filter win,$(MAKECMDGOALS)),)
    PLATFORM := win
endif
ifneq ($(filter nix,$(MAKECMDGOALS)),)
    PLATFORM := nix
endif

# Platform-Specific Settings
ifeq ($(PLATFORM),win)
    EXE := $(BUILD_DIR)/oxnag.exe
    ASM := nasm
    ASM_FLAGS := -f win64 -g -DTARGET_OS=OS_WINDOWS
    LINKER := link
    LINKER_FLAGS := /NOLOGO /ENTRY:_start /SUBSYSTEM:WINDOWS /MACHINE:X64 /DEBUG -out:$(EXE)
else
    EXE := $(BUILD_DIR)/oxnag
    ASM := nasm
    ASM_FLAGS := -f elf64 -g -DTARGET_OS=OS_LINUX
    LINKER := ld
    LINKER_FLAGS := --dynamic-linker /lib64/ld-linux-x86-64.so.2 -o $(EXE) -e _start --copy-dt-needed-entries -lc
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
.PHONY: all clean run size help win nix x11 wayland dswind compile compile_gltf_lib link banner

# Default Target
all: banner $(PLATFORM)

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

# Link Object Files
link:
	@printf "\n==============[ LINKING ]==============\n"
	@$(LINKER) $(LINKER_FLAGS) $(ALL_OBJS) $(OBJ_CGLTF_LIB) $(LIBS)

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

# Windows Build
win: banner compile

# *nix Build
nix: banner compile

