/* Note, that characters '0', '@' and 'P' (maybe others) do not work
   correctly on this display - change them before outputting!

   This program is based on this
   https://www.electronicwings.com/avr-atmega/interfacing-lcd-16x2-in-4-bit-mode-with-atmega-16-32-

   Shortening contrast pin (aka V0 aka VEE aka pin #3) to ground gives highest contrast.
*/

/*
   RS (Register Select) pin: 1 - data is sent, 0 - command is sent
   EN (Enable) pin: after you configure RS, set to 1 to enable operation and wait for the minimum
     amount of time required by the LCD and set to 0 again
   R/W (Read/Write) pin: 1 - read from LCD, 0 - write to LCD; we permanently set it
     to 0 - we just need to control EN and RS pins to send data
     (FIXME: is connecting it to ground a valid way to set it to 0? maybe try digital pin
      maybe this is the reason that it works badly)
   VEE to ground - ??? what is it? mozhet iz-za etogo glyuchit - poprob. posadit na cifrovoj pin
*/

/*
TODO: try to add PORTF=0; in the end of LCD_Command and LCD_Char
*/

#include <avr/io.h>
#define F_CPU 16000000UL
#include <util/delay.h>

void LCD_Command(unsigned char cmnd)
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

void LCD_Init(void)
{
  DDRF |= 0xF0;
  DDRB |= 1 << PB4 | 1 << PB5;

  DDRE |= 1 << PE6;
  PORTE |= 1 << PE6;
  _delay_ms(20);                  /* LCD Power ON delay always >15ms */
  DDRE &= ~(1 << PE6); /* PROBLEM: why enabling this pin to ON permanently
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
