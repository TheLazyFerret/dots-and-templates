#! Author: TheLazyFerret (https://github.com/TheLazyFerret)
#!
#! Makefile template rules for simple program compilation.

# Macros
CXX         := g++
CXXSTD      := # C++ standard.
CXXFLAGS    := -Wall -pedantic -g -std=$(CXXSTD)
TARGET      := # Program name.

SRCS        := # List of source files paths.
OBJS        := $(SRCS:%.cc=%.o)
INCL        := # Include directory.

# Main target
all: $(TARGET)

# Linking
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $^ -o $@ -I $(INCL)

# Object compilation
%.o: %.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@ -I $(INCL)

# clean
clean:
	rm -f src/*.o

# Full clean
fclean: clean
	rm -f $(TARGET)
