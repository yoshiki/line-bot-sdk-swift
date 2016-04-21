OPTS = -Xlinker -L/usr/local/lib \
	-Xcc -I/usr/local/include
OS := $(shell uname)

VENICE_VAR = ./Packages/Venice-*/
VENICE_DIR = $(wildcard $(VENICE_VAR))

all:
	swift build --fetch
ifeq ($(OS),Darwin)
else
	mv $(VENICE_DIR)/Source/Venice/*/* $(VENICE_DIR)/Source/
	rm -fr $(VENICE_DIR)/Source/Venice
endif
	swift build $(OPTS)

clean:
	swift build --clean dist

xcode:
	swift build $(OPTS) --X
