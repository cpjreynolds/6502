AS=vasm6502_oldstyle
ASFLAGS=-Fbin -wdc02 -dotdir

TARGET=main.o
SOURCE=main.s

$(TARGET): $(SOURCE)
	$(AS) $(ASFLAGS) -o $@ $^

.PHONY: upload
upload:
	minipro -p AT28C256 -uP -w $(TARGET)

.PHONY: clean
clean:
	rm $(TARGET)
