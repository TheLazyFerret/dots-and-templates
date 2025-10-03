# Macros
CXX         := g++
CXXFLAGS    := -Wall -Werror -pedantic
TARGET      := # Project name

SRCS        := # Sources
OBJS        := $(SRCS:%.cc=%.o)

# Predeterminate target
all: $(TARGET)

# Linking
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $^ -o $@

# Each source compilation
%.o: %.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@

#  clean
clean:
	rm -f #directory/*.o

# Full clean
fclean: clean
	rm -f $(TARGET)
