MCU=atmega32u4

#TODO: try to put both .c files to one command
time-read:
	@avr-gcc -mmcu=$(MCU) -g -Os -c $@.c
	@avr-gcc -mmcu=$(MCU) -g -Os -c LCD.c -DF_CPU=16000000UL
	@avr-gcc -mmcu=$(MCU) -g -o fw.elf $@.o LCD.o
	@avr-objcopy -O ihex fw.elf fw.hex

flash:
	@avrdude -qq -c usbasp -p $(MCU) -U flash:w:fw.hex
