all:
	@echo run "'make hostname'"

c.1:
	ctangle time reverse
	@make --no-print-directory time

c.2:
	ctangle time seconds
	@make --no-print-directory time

v:
	ctangle time reverse
	@make --no-print-directory time

t:
	ctangle time
	@make --no-print-directory time

u:
	ctangle time
	@make --no-print-directory time

m:
	ctangle time reverse
	@make --no-print-directory time  

time:
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
