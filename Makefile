OPTS = -Xlinker -L/usr/local/lib \
	-Xcc -I/usr/local/include \
	-Xswiftc -I/usr/local/include
OS := $(shell uname)

VENICE_DIR = ./Packages/Venice-*

all:
	swift build --fetch
ifneq ($(OS),Darwin)
	@if [ -d "$(VENICE_DIR)" ]; then \
		mv $(VENICE_DIR)/Source/Venice/*/* $(VENICE_DIR)/Source/ ;\
		rm -fr $(VENICE_DIR)/Source/Venice ;\
	fi
endif
	swift build $(OPTS)

clean:
	swift build --clean dist

xcode:
	swift build $(OPTS) -X
