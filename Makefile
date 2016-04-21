OPTS=-Xlinker -L/usr/local/lib \
	-Xcc -I/usr/local/include

all:
	swift build $(OPTS)

clean:
	swift build --clean dist

xcode:
	swift build $(OPTS) --X
