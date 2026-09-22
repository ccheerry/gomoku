NAME        := Gomoku

CC          ?= cc
CXX         ?= c++
AR          ?= ar

BUILD       ?= build
OPT         ?= -O3 -march=native -DNDEBUG
LDOPT       ?=
SAN         := -O1 -g3 -fsanitize=address,undefined -fno-omit-frame-pointer

# srcs
ENGINE_SRC  := $(wildcard src/engine/*.cpp)
AI_SRC      := $(wildcard src/ai/*.cpp)
UI_SRC      := $(wildcard src/ui/*.cpp)
APP_SRC     := src/main.cpp
TEST_SRC    := $(wildcard tests/*.cpp)

RAYLIB_DIR  := lib/raylib/src
RAYLIB_SRC  := $(addprefix $(RAYLIB_DIR)/,rcore.c rshapes.c rtextures.c rtext.c rmodels.c raudio.c rglfw.c)
IMGUI_DIR   := lib/imgui
RLIMGUI_DIR := lib/rlImGui
IMGUI_SRC   := $(addprefix $(IMGUI_DIR)/,imgui.cpp imgui_draw.cpp imgui_tables.cpp imgui_widgets.cpp) \
               $(RLIMGUI_DIR)/rlImGui.cpp

obj          = $(patsubst %,$(BUILD)/obj/%.o,$(basename $(1)))
CORE_OBJ    := $(call obj,$(ENGINE_SRC) $(AI_SRC))
APP_OBJ     := $(call obj,$(UI_SRC) $(APP_SRC))
TEST_OBJ    := $(call obj,$(TEST_SRC))
RAYLIB_OBJ  := $(call obj,$(RAYLIB_SRC))
IMGUI_OBJ   := $(call obj,$(IMGUI_SRC))
LIB_RAYLIB  := $(BUILD)/lib/libraylib.a
LIB_IMGUI   := $(BUILD)/lib/libimgui.a

# flags
WARN        := -Wall -Wextra -Werror -Wshadow -Wpedantic
INC         := -Isrc -isystem $(RAYLIB_DIR) -isystem $(IMGUI_DIR) -isystem $(RLIMGUI_DIR) -isystem lib/doctest
CXXFLAGS    := -std=c++20 $(WARN) $(OPT) $(INC) -MMD -MP
TP_CFLAGS   := -std=gnu99 -O2 -w -D_GNU_SOURCE -DPLATFORM_DESKTOP_GLFW -D_GLFW_X11 -DGRAPHICS_API_OPENGL_33 \
               -I$(RAYLIB_DIR) -I$(RAYLIB_DIR)/external/glfw/include -MMD -MP
TP_CXXFLAGS := -std=c++20 -O2 -w -I$(IMGUI_DIR) -I$(RLIMGUI_DIR) -I$(RAYLIB_DIR) -MMD -MP

LDLIBS      := -lm -lpthread -ldl -lrt -lX11

all: $(NAME)

$(NAME): $(CORE_OBJ) $(APP_OBJ) $(LIB_IMGUI) $(LIB_RAYLIB)
	$(CXX) $(LDOPT) $^ -o $@ $(LDLIBS)

$(BUILD)/run_tests: $(CORE_OBJ) $(TEST_OBJ)
	$(CXX) $(LDOPT) $^ -o $@ -lpthread

$(LIB_RAYLIB): $(RAYLIB_OBJ)
	@mkdir -p $(@D)
	$(AR) rcs $@ $^

$(LIB_IMGUI): $(IMGUI_OBJ)
	@mkdir -p $(@D)
	$(AR) rcs $@ $^

$(BUILD)/obj/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD)/obj/lib/%.o: lib/%.c
	@mkdir -p $(@D)
	$(CC) $(TP_CFLAGS) -c $< -o $@

$(BUILD)/obj/lib/%.o: lib/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(TP_CXXFLAGS) -c $< -o $@

test:
	@$(MAKE) --no-print-directory BUILD=build/debug OPT="$(SAN)" LDOPT="-fsanitize=address,undefined" build/debug/run_tests
	./build/debug/run_tests

debug:
	@$(MAKE) --no-print-directory BUILD=build/debug OPT="$(SAN)" LDOPT="-fsanitize=address,undefined" \
		NAME=build/debug/Gomoku build/debug/Gomoku

bench: $(NAME)
	./$(NAME) --bench

coverage:
	@$(MAKE) --no-print-directory BUILD=build/coverage OPT="-O0 -g --coverage" LDOPT="--coverage" build/coverage/run_tests
	./build/coverage/run_tests
	gcovr --root . --filter 'src/engine/' --filter 'src/ai/' --exclude 'src/ai/(bench|arena)\.cpp' \
		--fail-under-line 80 build/coverage

clean:
	rm -rf build

fclean: clean
	rm -f $(NAME)

re: fclean
	@$(MAKE) --no-print-directory all

-include $(CORE_OBJ:.o=.d) $(APP_OBJ:.o=.d) $(TEST_OBJ:.o=.d) $(RAYLIB_OBJ:.o=.d) $(IMGUI_OBJ:.o=.d)

.PHONY: all test debug bench coverage clean fclean re
