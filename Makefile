all:
	@echo run "'make hostname'"

c.1:
	tie -c time.ch time.w reverse.ch brightness.ch >/dev/null
	ctangle time time
	@make --no-print-directory time

c.2:
	tie -c time.ch time.w seconds.ch brightness.ch >/dev/null
	ctangle time time
	@make --no-print-directory time

kitchen:
	tie -c time.ch time.w reverse.ch brightness.ch >/dev/null
	ctangle time time
	@make --no-print-directory time

time:
	avr-gcc -mmcu=atmega32u4 -DF_CPU=16000000UL -g -Os -o fw.elf time.c
	avr-objcopy -O ihex fw.elf fw.hex

flash:
	avrdude -qq -c usbasp -p atmega32u4 -U efuse:v:0xcb:m -U hfuse:v:0xd9:m -U lfuse:v:0xff:m -U flash:w:fw.hex

eps:
	@make --no-print-directory `grep -o '^\S*\.eps' Makefile`
	@make --no-print-directory -C ../usb eps

.PHONY: $(wildcard *.eps)

INKSCAPE=inkscape --export-type=eps --export-ps-level=2 -T -o $@ 2>/dev/null

arduino.eps:
	@$(INKSCAPE) arduino.svg

time.eps:
	@$(INKSCAPE) time.svg
