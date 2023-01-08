#!/bin/bash

clang++ -Iincludes -lglfw \
  -framework CoreVideo -framework OpenGL -framework IOKit -framework Cocoa -framework Carbon \
  glad.o $1
