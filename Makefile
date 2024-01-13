all:
	@echo NoOp

I:
	tie -c time.ch time.w reverse.ch blink.ch >/dev/null
	ctangle time time
	@make --no-print-directory time

II:
	tie -c time.ch time.w seconds.ch blink.ch >/dev/null
	ctangle time time
	@make --no-print-directory time

k:
	tie -c time.ch time.w reverse.ch blink.ch >/dev/null
	ctangle time time
	@make --no-print-directory time

time:
	avr-gcc -mmcu=atmega32u4 -DF_CPU=16000000UL -g -Os -o fw.elf time.c
	avr-objcopy -O ihex fw.elf fw.hex

flash:
	avrdude -qq -c usbasp -p atmega32u4 -U efuse:v:0xcb:m -U hfuse:v:0xd9:m -U lfuse:v:0xff:m -U flash:w:fw.hex

eps:
	@make --no-print-directory `grep -o '^\S*\.eps' Makefile`

.PHONY: $(wildcard *.eps)

arduino.eps:
	@$(inkscape) arduino.svg

time.eps:
	@$(inkscape) time.svg

usb.eps:
	@$(inkscape) usb.svg

inkscape=inkscape --export-type=eps --export-ps-level=2 -T -o $@ 2>/dev/null
