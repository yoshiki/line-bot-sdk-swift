OPTS=-Xlinker -L/usr/local/lib \
	-Xcc -I/usr/local/include
OS := $(shell uname)

all:
	swift build --fetch
ifeq ($(OS),Darwin)
else
	@echo "Build on Linux"
	mv Packages/Venice-*/Source/Venice/* Packages/Venice-*/Source/
	rm -fr Packages/Venice-*/Source/Venice
endif
	swift build $(OPTS)

clean:
	swift build --clean dist

xcode:
	swift build $(OPTS) --X
