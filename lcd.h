/* See https://www.instructables.com/id/I2C-Backlight-Control-of-an-LCD-Display-1602-or-20/ for
I2C backlight

   This program is based on this
   https://www.electronicwings.com/avr-atmega/interfacing-lcd-16x2-in-4-bit-mode-with-atmega-16-32-

   Never short contrast pin (aka V0 aka VEE aka pin #3) to ground!!! Always use variable
   10k resistor to create voltage divider for contrast pin and adjust it.
*/

/*
   RS (Register Select) pin: 1 - data is sent, 0 - command is sent
   EN (Enable) pin: after you configure RS, set to 1 to enable operation and wait for the minimum
     amount of time required by the LCD and set to 0 again
   R/W (Read/Write) pin: 1 - read from LCD, 0 - write to LCD; we permanently set it
     to 0 by shortening it to ground - we just need to control EN and RS pins to write data
*/

/*
  TODO: try to add PORTD=0; in the end of LCD_Command and LCD_Char
*/

#include <avr/io.h>
#define F_CPU 16000000UL
#include <util/delay.h>

void LCD_Command(unsigned char cmnd)
{
        PORTD = cmnd >> 4; /* sending upper nibble */

        PORTB |= 1 << PB6; // E(1)
        _delay_us(1);
        PORTB &= ~(1 << PB6); // E(0)

        PORTD = cmnd & 0x0F;  /* sending lower nibble */

        PORTB |= 1 << PB6; // E(1)
        _delay_us(1);
        PORTB &= ~(1 << PB6); // E(0)

  _delay_ms(2); // empirical
}

void LCD_Char(unsigned char data)
{
        PORTD = data >> 4; /* sending upper nibble */

        PORTB |= 1 << PB4 | 1 << PB6; // RS(1) E(1)
        _delay_us(1);
        PORTB &= ~(1 << PB4 | 1 << PB6); // RS(0) E(0)

        PORTD = data & 0x0F; /* sending lower nibble */

        PORTB |= 1 << PB4 | 1 << PB6; // RS(1) E(1)
        _delay_us(1);
        PORTB &= ~(1 << PB4 | 1 << PB6); // RS(0) E(0)

  _delay_us(100); // empirical
}

void LCD_Init(void)
{
  DDRD |= 0x0F;
  DDRB |= 1 << PB4 | 1 << PB6;

  _delay_ms(20);                  /* LCD Power ON delay always >15ms TODO: test this to ensure */

  LCD_Command(0x02);              /* send for 4 bit initialization of LCD  */
  LCD_Command(0x28);              /* 2 line, 5*7 matrix in 4-bit mode */
  LCD_Command(0x0c);              /* Display on cursor off*/
  LCD_Command(0x06);              /* Increment cursor (shift cursor to right)*/
  LCD_Command(0x01);              /* Clear display screen*/
}
