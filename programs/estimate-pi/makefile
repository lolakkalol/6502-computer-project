# Linker and compiler used
CC="ca65"
LD="ld65"

# build dir
dir=./build

# Flags used
CFLAGS= -W3 --cpu 65C02 --verbose
LFLAGS= -C target.cfg -v

all: clean prog

prog: $(dir)/main.o $(dir)/lib.o $(dir)/start.o
	$(LD) $(dir)/main.o $(dir)/lib.o $(LFLAGS) $(dir)/start.o -o main.bin

$(dir)/main.o:
	@mkdir build
	$(CC) main.asm -o $(dir)/main.o $(CFLAGS)

$(dir)/lib.o:
	$(CC) lib.asm -o $(dir)/lib.o $(CFLAGS)

$(dir)/start.o:
	$(CC) start.asm -o $(dir)/start.o $(CFLAGS)

clean:
	rm -rf $(dir)