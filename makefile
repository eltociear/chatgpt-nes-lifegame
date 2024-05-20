AS = ca65
LD = ld65

SRC = asm/main.asm asm/grid.asm asm/graphics.asm
OBJ = $(SRC:.asm=.o)
TARGET = build/life_game.nes

all: $(TARGET)

$(TARGET): $(OBJ)
	$(LD) -C nes.cfg -o $(TARGET) $(OBJ)

%.o: %.asm
	$(AS) -o $@ $<

clean:
	rm -f asm/*.o $(TARGET)
