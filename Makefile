MCU=atmega32u4

time-read lcd max max4:
	@avr-gcc -mmcu=$(MCU) -DF_CPU=16000000UL -g -Os -o fw.elf $@.c
	@avr-objcopy -O ihex fw.elf fw.hex

flash:
	@avrdude -qq -c usbasp -p $(MCU) -U flash:w:fw.hex

imgs:
	@mp MAX
	@perl -ne 'if (/^(.*\.eps): (.*)/) { system "convert $$2 $$1" }' Makefile

.PHONY: $(wildcard *.eps)

max4.eps: max4.png
	@convert $< $@
	@imgsize $@ 7 -

max.eps: max.png
	@convert $< $@
	@imgsize $@ 7 -
