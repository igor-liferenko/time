MCU=atmega32u4

time-read lcd max max4:
	@avr-gcc -mmcu=$(MCU) -g -Os -o fw.elf $@.c
	@avr-objcopy -O ihex fw.elf fw.hex

flash:
	@avrdude -qq -c usbasp -p $(MCU) -U flash:w:fw.hex

imgs:
	@mp MAX
	@perl -ne 'if (/^(.*\.eps): (.*)/) { system "convert $$2 $$1" }' Makefile

.PHONY: $(wildcard *.eps)

max4-1.eps: max4-1.png
	@convert $< $@
	@imgsize $@ 7 -

max4-2.eps: max4-2.png
	@convert $< $@
	@imgsize $@ 7 -

max4-3.eps: max4-3.png
	@convert $< $@
	@imgsize $@ 7 -
