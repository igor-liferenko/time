MCU=atmega32u4

time-read max4:
	@avr-gcc -mmcu=$(MCU) -DF_CPU=16000000UL -g -Os -o fw.elf $@.c
	@avr-objcopy -O ihex fw.elf fw.hex

flash:
	@unbuffer avrdude -c usbasp -p $(MCU) | grep -q 'Fuses OK (E:CB, H:D9, L:FF)'
	@avrdude -qq -c usbasp -p $(MCU) -U flash:w:fw.hex

imgs:
	@mp max4
	@perl -ne 'if (/^(.*\.eps): (.*)/) { system "convert $$2 $$1" }' Makefile

.PHONY: $(wildcard *.eps)

max4-pic.eps: max4-pic.png
	@convert $< $@
	@imgsize $@ 7 -
