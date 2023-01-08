# Simple OpenGL on macOS

## Setup

**Dependencies**

```Bash
# basic
brew install cmake glfw
# other useful
brew install assimp glm freetype
```

**Compile**

```Bash
clang -c glad.c -Iincludes
# or use a bash script
./build_glash.sh
```

This creates `glad.o` file at the root directory.

## Usage

Basic command:

```Bash
clang++ -lglfw \
  -framework CoreVideo -framework OpenGL -framework IOKit -framework Cocoa -framework Carbon \
  -Iincludes \
  glad.o <cpp_file_name>
```

Use bash script:

```Bash
./build.sh cpp_file_name
```

Executable is by default `a.out`.
