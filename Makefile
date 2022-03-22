all:
	@echo ERROR: run 'make N'

4:
	ctangle time
	make fw.hex

fw.hex: time.c
	@avr-gcc -mmcu=atmega32u4 -DF_CPU=16000000UL -g -Os -o fw.elf time.c
	@avr-objcopy -O ihex fw.elf fw.hex

flash:
	@avrdude -qq -c usbasp -p atmega32u4 -U efuse:v:0xcb:m -U hfuse:v:0xd9:m -U lfuse:v:0xff:m -U flash:w:fw.hex

imgs:
	@mpost time
	@perl -ne 'if (/^(.*\.eps): (.*)/) { system "convert $$2 eps2:$$1" }' Makefile

.PHONY: $(wildcard *.eps)

max4.eps: max4.png
	@convert $< eps2:$@
	@imgsize $@ 7 -
