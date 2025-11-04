#! Author TheLazyFerret (https://github.com/TheLazyFerret)
#! Copyright (c) 2025 TheLazyFerret.
#!   Using the license MIT.
#!   See the LICENSE file in the project root for full license information.
#!
#! Makefile rules for simple program compilation.

# Macros
CXX         := g++
CXXSTD      := c++23
CXXFLAGS    := -Wall -Werror -pedantic -g -o3
TARGET      := # Add target name.

SRCS        := # Source files of the program.
OBJS        := $(SRCS:%.cc=%.o)
INCL        := # Add -I$(INCL) if there are files to include.

# Main target
all: $(TARGET)

# Linking
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -std=$(CXXSTD) $^ -o $@

# Object compilation
%.o: %.cc
	$(CXX) $(CXXFLAGS) -std=$(CXXSTD) -c $< -o $@

# clean
clean:
	rm -f src/*.o

# Full clean
fclean: clean
	rm -f $(TARGET)
