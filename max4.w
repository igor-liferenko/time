\let\lheader\rheader
%\datethis
\secpagedepth=2 % begin new page only on *
\font\caps=cmcsc10 at 9pt

@* Program.

$$\hbox to7cm{\vbox to5.82cm{\vfil\special{psfile=max4-pic.eps
  clip llx=0 lly=0 urx=179 ury=149 rwi=1984}}\hfil}$$

$$\hbox to7.16cm{\vbox to2.99861111111111cm{\vfil\special{psfile=max4.1
  clip llx=-63 lly=84 urx=140 ury=169 rwi=2030}}\hfil}$$

@c
@<Header files@>@;
@<Type definitions@>@;
@<Global variables@>@;
@<Functions@>@;
@<Create ISR for connecting to USB host@>@;

void main(void)
{
  @<Connect to USB host (must be called first; |sei| is called here)@>@;

  @<Initialize display@>@;

  while (1) {
    @<If there is a request on |EP0|, handle it@>@;
    UENUM = EP2;
    if (UEINTX & 1 << RXOUTI) {
      UEINTX &= ~(1 << RXOUTI);
      char str[9];
      int rx_counter = UEBCLX;
      while (rx_counter--)
        str[7-rx_counter] = UEDATX;
      UEINTX &= ~(1 << FIFOCON);
      str[8] = '\0';
      if (strcmp(str, "06:00:00") == 0)
        display_write4(0x0A, 0x0F);
      if (strcmp(str, "21:00:00") == 0)
        display_write4(0x0A, 0x03);
      str[5] = '\0';
      @<Show |str|@>@;
    }
  }
}

@ Initialization of all registers must be done, because they may contain garbage.
First make sure that test mode is disabled, because it overrides all registers.
Next, make sure that display is disabled, because there may be random lighting LEDs on it.
Then set decode mode to properly clear all LEDs,
and clear them. Finally, configure the rest registers and enable the display.

Note, that |PB0| must be set to OUTPUT for SPI master.
FIXME: PB0 led is damaged on board on which I did this first clock,
so for next clock we have to set it HIGH here because on pro-micro leds are inverted, and if it
will not work in such case, don't set it to HIGH here and cut-off the resistor
which goes to PB0 led instead

SPI here is used as a way to push bytes to display (data + clock).
Latch is used only in the end, like in shift registers.
Frequency of SPI clock is adjusted empirically (starting from highest).
Latch duration which should be safe is 1$\mu$s (minimum is 50ns according to datasheet).
It can also be adjusted, but after frequency - use NOP's to decrease it.
Take into accound capacitance of wires for SPI - signal may raise and fall with some latency
(clock and latch are in parallel, DIN goes through each device to DOUT and then to DIN of
next device in a chain).

@<Initialize display@>=
DDRB |= 1 << PB0 | 1 << PB1 | 1 << PB2 | 1 << PB6;
SPCR |= 1 << MSTR | 1 << SPR1 | 1 << SPE;
display_write4(0x0F, 0x00);
display_write4(0x0C, 0x00);
display_write4(0x09, 0x00);
display_write4(0x01, 0x00);
display_write4(0x02, 0x00);
display_write4(0x03, 0x00);
display_write4(0x04, 0x00);
display_write4(0x05, 0x00);
display_write4(0x06, 0x00);
display_write4(0x07, 0x00);
display_write4(0x08, 0x00);
display_write4(0x0A, 0x0F);
display_write4(0x0B, 0x07);
display_write4(0x0C, 0x01);

@ To output the characters we use a buffer. Buffer is necessary because
outputting to a device is done in 8-element rows, and width of each character (with space)
is not exactly 8. And buffer is easy to divide into portions. This picture shows
how row is set on each device.

$$\hbox to8.46cm{\vbox to2.04611111111111cm{\vfil\special{psfile=max4.2
  clip llx=-27 lly=-26 urx=213 ury=32 rwi=2400}}\hfil}$$

@d NUM_DEVICES 4

@<Show |str|@>=
uint8_t buffer[8][NUM_DEVICES*8];
@<Fill buffer@>@;
@<Display buffer@>@;

@ @d app_to_buf(chr)
     for (int i = 0; i < sizeof chr / 8; i++) buffer[row][col--] = pgm_read_byte(&chr[row][i])

@<Fill buffer@>=
for (int row = 0; row < 8; row++) {
  int col = NUM_DEVICES*8 - 1;
  buffer[row][col--] = 0x00;
  for (char *c = str; *c != '\0'; c++) {
    switch (*c)
    {
    case '0':
      app_to_buf(digit_0);
      break;
    case '1':
      app_to_buf(digit_1);
      break;
    case '2':
      app_to_buf(digit_2);
      break;
    case '3':
      app_to_buf(digit_3);
      break;
    case '4':
      app_to_buf(digit_4);
      break;
    case '5':
      app_to_buf(digit_5);
      break;
    case '6':
      app_to_buf(digit_6);
      break;
    case '7':
      app_to_buf(digit_7);
      break;
    case '8':
      app_to_buf(digit_8);
      break;
    case '9':
      app_to_buf(digit_9);
      break;
    case ':':
      app_to_buf(colon);
      break;
    }
    buffer[row][col--] = 0x00;
  }
}

@ Displaying is done in rows (i.e., row address is used in show command), from top row to
bottom row.
Left device is set first, right device is set last.

@<Display buffer@>=
for (int row = 0; row < 8; row++) {
  uint8_t data;
  for (int n = NUM_DEVICES; n > 0; n--) {
    data = 0x00;
    for (int i = 0; i < 8; i++)
      if (buffer[row][(n-1)*8+i])
        data |= 1 << i;
    display_push(row+1, data);
  }
  PORTB |= 1 << PB6; @+ _delay_us(1); @+ PORTB &= ~(1 << PB6);
}

@ @<Functions@>=
void display_push(uint8_t address, uint8_t data) 
{
  SPDR = address;
  while (~SPSR & 1 << SPIF) ;
  SPDR = data;
  while (~SPSR & 1 << SPIF) ; 
}

@ @<Functions@>=
void display_write4(uint8_t address, uint8_t data)
{
  for (int i = 0; i < NUM_DEVICES; i++)
    display_push(address, data);
  PORTB |= 1 << PB6; @+ _delay_us(1); @+ PORTB &= ~(1 << PB6);
}

@ @<Global variables@>=
@<Character images@>@;

@ @<Char...@>=
const uint8_t digit_0[8][5]
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/
  { 0, 1, 1, 1, 0 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 0, 1, 1, 1, 0 }, @/
@t\2@> { 0, 0, 0, 0, 0 } @/
};

@ @<Char...@>=
const uint8_t digit_1[8][5]
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/
  { 0, 0, 1, 0, 0 }, @/
  { 0, 1, 1, 0, 0 }, @/
  { 0, 0, 1, 0, 0 }, @/
  { 0, 0, 1, 0, 0 }, @/
  { 0, 0, 1, 0, 0 }, @/
  { 0, 0, 1, 0 ,0 }, @/
  { 0, 1, 1, 1, 0 }, @/
@t\2@> { 0, 0, 0, 0, 0 } @/
};

@ @<Char...@>=
const uint8_t digit_2[8][5]
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/  
  { 0, 1, 1, 1, 0 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 0, 0, 0, 0, 1 }, @/
  { 0, 0, 0, 1, 0 }, @/
  { 0, 0, 1, 0, 0 }, @/
  { 0, 1, 0, 0, 0 }, @/
  { 1, 1, 1, 1, 1 }, @/
@t\2@> { 0, 0, 0, 0, 0 } @/
};

@ @<Char...@>=
const uint8_t digit_3[8][5]
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/  
  { 1, 1, 1, 1, 1 }, @/
  { 0, 0, 0, 1, 0 }, @/
  { 0, 0, 1, 0, 0 }, @/
  { 0, 0, 0, 1, 0 }, @/
  { 0, 0, 0, 0, 1 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 0, 1, 1, 1, 0 }, @/
@t\2@> { 0, 0, 0, 0, 0 } @/
};

@ @<Char...@>=
const uint8_t digit_4[8][5]
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/
  { 0, 0, 0, 1, 0 }, @/
  { 0, 0, 1, 1, 0 }, @/
  { 0, 1, 0, 1, 0 }, @/
  { 1, 0, 0, 1, 0 }, @/
  { 1, 1, 1, 1, 1 }, @/
  { 0, 0, 0, 1, 0 }, @/
  { 0, 0, 0, 1, 0 }, @/
@t\2@> { 0, 0, 0, 0, 0 } @/
};

@ @<Char...@>=
const uint8_t digit_5[8][5]
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/
  { 1, 1, 1, 1, 1 }, @/
  { 1, 0, 0, 0, 0 }, @/
  { 1, 1, 1, 1, 0 }, @/
  { 0, 0, 0, 0, 1 }, @/
  { 0, 0, 0, 0, 1 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 0, 1, 1, 1, 0 }, @/
@t\2@> { 0, 0, 0, 0, 0 } @/
};

@ @<Char...@>=
const uint8_t digit_6[8][5]
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/
  { 0, 0, 1, 1, 0 }, @/
  { 0, 1, 0, 0, 0 }, @/
  { 1, 0, 0, 0, 0 }, @/
  { 1, 1, 1, 1, 0 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 0, 1, 1, 1, 0 }, @/
@t\2@> { 0, 0, 0, 0, 0 } @/
};

@ @<Char...@>=
const uint8_t digit_7[8][5]
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/
  { 1, 1, 1, 1, 1 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 0, 0, 0, 1, 0 }, @/
  { 0, 0, 1, 0, 0 }, @/
  { 0, 1, 0, 0, 0 }, @/
  { 0, 1, 0, 0, 0 }, @/
  { 0, 1, 0, 0, 0 }, @/
@t\2@> { 0, 0, 0, 0, 0 } @/
};

@ @<Char...@>=
const uint8_t digit_8[8][5]
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/
  { 0, 1, 1, 1, 0 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 0, 1, 1, 1, 0 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 0, 1, 1, 1, 0 }, @/
@t\2@> { 0, 0, 0, 0, 0 } @/
};

@ @<Char...@>=
const uint8_t digit_9[8][5]
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/
  { 0, 1, 1, 1, 0 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 1, 0, 0, 0, 1 }, @/
  { 0, 1, 1, 1, 1 }, @/
  { 0, 0, 0, 0, 1 }, @/
  { 0, 0, 0, 1, 0 }, @/
  { 0, 1, 1, 0, 0 }, @/
@t\2@> { 0, 0, 0, 0, 0 } @/
};

@ @<Char...@>=
const uint8_t colon[8][6]
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/
  { 0, 0, 0, 0, 0, 0 }, @/
  { 0, 0, 1, 1, 0, 0 }, @/
  { 0, 0, 1, 1, 0, 0 }, @/
  { 0, 0, 0, 0, 0, 0 }, @/
  { 0, 0, 1, 1, 0, 0 }, @/
  { 0, 0, 1, 1, 0, 0 }, @/
  { 0, 0, 0, 0, 0, 0 }, @/
@t\2@> { 0, 0, 0, 0, 0, 0 } @/
};

@ No other requests except {\caps set control line state} come
after connection is established. These are from \\{open} and implicit \\{close}
in \.{time-write}. Just discard the data.

@<If there is a request on |EP0|, handle it@>=
UENUM = EP0;
if (UEINTX & 1 << RXSTPI) {
  UEINTX &= ~(1 << RXSTPI);
  UEINTX &= ~(1 << TXINI); /* STATUS stage */
}

@i ../usb/OUT-endpoint-management.w
@i ../usb/USB.w

@ Program headers are in separate section from USB headers.

@<Header files@>=
#include <avr/io.h>
#include <avr/pgmspace.h> /* |pgm_read_byte| */
#include <string.h> /* |strcmp| */
#include <util/delay.h> /* |_delay_us| */

@* Index.
