@ There is a gotcha: if character is '0' or '@' or 'P' - it does not work - change
it before outputting!

This program is based on this
https://www.electronicwings.com/avr-atmega/interfacing-lcd-16x2-in-4-bit-mode-with-atmega-16-32-

shortening contrast pin (aka V0 aka VEE aka pin #3) to ground gives highest contrast

@c
#define F_CPU 16000000UL
#include <avr/io.h>			/* Include AVR std. library file */
#include <util/delay.h>			/* Include Delay header file */

void LCD_Command( unsigned char cmnd )
{
        PORTF = cmnd & 0xF0; /* sending upper nibble */

        PORTB |= 1 << PB5; // E(1)
        _delay_us(1);
        PORTB &= ~(1 << PB5); // E(0)

        PORTF = cmnd << 4;  /* sending lower nibble */

        PORTB |= 1 << PB5; // E(1) 
        _delay_us(1);
        PORTB &= ~(1 << PB5); // E(0)

  _delay_ms(2); // empirical
}

void LCD_Char(unsigned char data)
{
        PORTF = data & 0xF0; /* sending upper nibble */

        PORTB |= 1 << PB4 | 1 << PB5; // RS(1) E(1)
        _delay_us(1);
        PORTB &= ~(1 << PB4 | 1 << PB5); // RS(0) E(0)

        PORTF = data << 4; /* sending lower nibble */

        PORTB |= 1 << PB4 | 1 << PB5; // RS(1) E(1)
        _delay_us(1);
        PORTB &= ~(1 << PB4 | 1 << PB5); // RS(0) E(0)

  _delay_us(100); // empirical
}

void LCD_Init (void)
{
  DDRF |= 0xF0;
  DDRB |= 1 << PB4 | 1 << PB5;

  DDRD |= 1 << PD0;
  PORTD |= 1 << PD0;
  _delay_ms(20);                  /* LCD Power ON delay always >15ms */
  DDRD &= ~(1 << PD0); /* PROBLEM: why enabling this pin to ON permanently
    (i.e., using 5v) gives black background?
    When you find out, re-solder wire from PE6 to VCC and solder backlight pins
    to pins #1 and #2 directly on display (or better to pin #5 because it has space for one more
    wire - otnesti v 105k. k Andreyu) */

  LCD_Command(0x02);              /* send for 4 bit initialization of LCD  */
  LCD_Command(0x28);              /* 2 line, 5*7 matrix in 4-bit mode */
  LCD_Command(0x0c);              /* Display on cursor off*/
  LCD_Command(0x06);              /* Increment cursor (shift cursor to right)*/
  LCD_Command(0x01);              /* Clear display screen*/
}
