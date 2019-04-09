\let\lheader\rheader
%\datethis
\secpagedepth=2 % begin new page only on *
\font\caps=cmcsc10 at 9pt

@* Program.

$$\hbox to7cm{\vbox to5.82cm{\vfil\special{psfile=max4-pic.eps
  clip llx=0 lly=0 urx=179 ury=149 rwi=1984}}\hfil}$$

$$\hbox to7.16cm{\vbox to2.92805555555556cm{\vfil\special{psfile=MAX.1
  clip llx=-63 lly=96 urx=140 ury=179 rwi=2030}}\hfil}$$

@c
@<Header files@>@;
@<Type definitions@>@;
@<Global variables@>@;
@<Functions@>@;
@<Character images@>@;
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
      int rx_counter = UEBCLX;
      while (rx_counter--)
        str[7-rx_counter] = UEDATX;
      UEINTX &= ~(1 << FIFOCON);
      if (strcmp(str, "06:00:00") == 0)
        display_write4(0x0A, 0x0F);
      if (strcmp(str, "21:00:00") == 0)
        display_write4(0x0A, 0x03);
      str[5] = '\0'; @+ @<Show |str|@>@;
    }
  }
}

@ @<Global...@>=
char str[9];

@ Initialization of all registers must be done, because they may contain garbage.
First make sure that test mode is disabled, because it overrides all registers.
Next, make sure that display is disabled, because there may be random lighting LEDs on it.
Then set decode mode to properly clear all LEDs,
and clear them. Finally, configure the rest registers and enable the display.

@<Initialize display@>=
DDRB |= 1 << PB0 | 1 << PB1 | 1 << PB2 | 1 << PB4;
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

@ Buffer is necessary because the whole row must be known before outputting it to a given device.

@d NUM_DEVICES 4

@<Global...@>=
uint8_t buffer[8][NUM_DEVICES*8];

@ @<Show |str|@>=
@<Fill |buffer| from |str|@>@;
@<Display |buffer|@>@;

@ @d app_to_buf(chr)
     for (int i = 0; i < sizeof chr / 8; i++) buffer[row][col--] = pgm_read_byte(&chr[row][i])

@<Fill |buffer| from |str|@>=
  for (int row = 0; row < 8; row++) {
    int col = NUM_DEVICES*8-1-1; /* last `|-1|' is the number of padding columns from left
      edge of the whole display */
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
      buffer[row][col--] = 0x00; /* space between characters; note, that no boundary checking
        is done, because due to size of characters\footnote\dag{See |@<Char...@>|.} there
        is one free column on the right edge of the display */
    }
  }

@ Displaying is done in rows (i.e., row address is used in show command), from top row to
bottom row.
On each display each row is set from right to left.
Left device is set first, right device is set last.

$$\hbox to8.46cm{\vbox to2.04611111111111cm{\vfil\special{psfile=max4.1
  clip llx=-27 lly=-26 urx=213 ury=32 rwi=2400}}\hfil}$$

@<Display |buffer|@>=
  for (int row = 0; row < 8; row++) {
    uint8_t data;
    for (int n = NUM_DEVICES; n > 0; n--) {
      data = 0x00;
      for (int i = 0; i < 8; i++)
        if (buffer[row][(n-1)*8+i])
          data |= 1 << i;
      display_push(row+1, data);
    }
    PORTB |= 1 << PB4; _delay_us(1);@+ PORTB &= ~(1 << PB4);
  }

@ @<Functions@>=
void write_byte(uint8_t byte)
{
  SPDR = byte;
  while(!(SPSR & (1 << SPIF))); // FIXME: check op precedence to remove extra parens
}

@ @<Functions@>=
void display_push(uint8_t address, uint8_t data) 
{
  write_byte(address);
  write_byte(data);
}

@ @<Functions@>=
void display_write4(uint8_t address, uint8_t data)
{
  for (int i = 0; i < NUM_DEVICES; i++)
    display_push(address, data);
  PORTB |= 1 << PB4; @+_delay_us(1); PORTB &= ~(1 << PB4);
}

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
#include <util/delay.h>

@* Index.
