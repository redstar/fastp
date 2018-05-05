DIR_INC = ./inc
DIR_SRC = ./src
DIR_OBJ = ./obj
BINDIR=/usr/local/bin

CPP_SRC = $(wildcard ${DIR_SRC}/*.cpp)
CPP_OBJ = $(patsubst %.cpp,${DIR_OBJ}/%.o,$(notdir ${CPP_SRC}))
D_SRC = $(wildcard ${DIR_SRC}/*.d)
D_OBJ = $(patsubst %.d,${DIR_OBJ}/%.o,$(notdir ${D_SRC}))

SRC = ${CPP_SRC} ${D_SRC}
OBJ = ${CPP_OBJ} ${D_OBJ}

TARGET = fastp

BIN_TARGET = ${TARGET}

CC = g++
CFLAGS = -std=c++11 -g -I${DIR_INC}
DC = dmd
DFLAGS = -g -I${DIR_SRC}

all: make_obj_dir ${BIN_TARGET}

${BIN_TARGET}: ${OBJ}
	$(CC) $(OBJ) -lphobos2 -lz -lpthread -o $@

${DIR_OBJ}/%.o: ${DIR_SRC}/%.cpp
	$(CC) $(CFLAGS) -O3 -c  $< -o $@

${DIR_OBJ}/%.o: ${DIR_SRC}/%.d
	$(DC) $(DFLAGS) -O -c  $< -of$@

.PHONY: clean
clean:
	rm obj/*.o
	rm $(TARGET)

.PHONY: make_obj_dir
make_obj_dir:
	@if test ! -d $(DIR_OBJ) ; \
	then \
		mkdir $(DIR_OBJ) ; \
	fi

install:
	install $(TARGET) $(BINDIR)/$(TARGET)
	@echo "Installed."
