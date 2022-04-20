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

v:
	tie -c time.ch time.w reverse.ch brightness.ch >/dev/null
	ctangle time time
	@make --no-print-directory time

t:
	ctangle time brightness
	@make --no-print-directory time

u:
	ctangle time brightness
	@make --no-print-directory time

m:
	ctangle time reverse
	@make --no-print-directory time  

time:
	avr-gcc -mmcu=atmega32u4 -DF_CPU=16000000UL -g -Os -o fw.elf time.c
	avr-objcopy -O ihex fw.elf fw.hex

flash:
	avrdude -qq -c usbasp -p atmega32u4 -U efuse:v:0xcb:m -U hfuse:v:0xd9:m -U lfuse:v:0xff:m -U flash:w:fw.hex

img:
	@mpost time
	@perl -ne 'if (/^(.*\.eps):$$/) { system "make --no-print-directory $$1" }' Makefile

.PHONY: $(wildcard *.eps)

max4.eps:
	convert -resize 827 max4.png eps2:$@

time-1.eps:
	convert -resize 203 time.1 eps2:$@

time-2.eps:
	convert -resize 250 time.2 eps2:$@
