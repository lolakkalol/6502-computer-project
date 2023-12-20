# Linker and compiler used
CC=ca65
LD=ld65

# build dir
dir=./build

# Flags used
CFLAGS= -W3 --cpu 65C02 --verbose
LFLAGS= -C target.cfg -v

all: clean prog

prog: $(dir)/main.o
	$(LD) $(dir)/main.o $(LFLAGS) -o main.bin

$(dir)/main.o:
	@mkdir build
	$(CC) main.asm -o $(dir)/main.o $(CFLAGS)

clean:
	rm -rf $(dir)