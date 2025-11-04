#! Author TheLazyFerret (https://github.com/TheLazyFerret)
#! Copyright (c) 2025 TheLazyFerret.
#!   Using the license MIT.
#!   See the LICENSE file in the project root for full license information.
#!
#! Makefile rules for simple program compilation.

# Macros
CXX         := g++
CXXSTD      := c++23
CXXFLAGS    := -Wall -pedantic -g -o3 -std=$(CXXSTD)
TARGET      := 

SRCS        := 
OBJS        := $(SRCS:%.cc=%.o)
INCL        := 

# Main target
all: $(TARGET)

# Linking
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $^ -o $@

# Object compilation
%.o: %.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@

# clean
clean:
	rm -f src/*.o

# Full clean
fclean: clean
	rm -f $(TARGET)
