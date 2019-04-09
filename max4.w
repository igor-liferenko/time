\let\lheader\rheader
%\datethis
\secpagedepth=2 % begin new page only on *
\font\caps=cmcsc10 at 9pt

@* Program.

$$\hbox to7cm{\vbox to5.82cm{\vfil\special{psfile=max4-pic.eps
  clip llx=0 lly=0 urx=179 ury=149 rwi=1984}}\hfil}$$

$$\hbox to5.64cm{\vbox to2.57527777777778cm{\vfil\special{psfile=MAX.1
  clip llx=-63 lly=96 urx=97 ury=169 rwi=1600}}\hfil}$$

Displaying is done in rows (i.e., row address is used in show command), from top row to bottom row.
On each display each row is set from right to left.
Left device is set first, right device is set last.

$$\hbox to8.46cm{\vbox to2.04611111111111cm{\vfil\special{psfile=max4.1
  clip llx=-27 lly=-26 urx=213 ury=32 rwi=2400}}\hfil}$$

@d NUM_DEVICES 4

@c
@<Header files@>@;
@<Type definitions@>@;
@<Global variables@>@;
@<Create ISR for connecting to USB host@>@;

#define SLAVE_SELECT    PORTB &= ~(1 << PB3)
#define SLAVE_DESELECT  PORTB |= 1 << PB3

#include <avr/io.h>
#include <avr/pgmspace.h>
#include <string.h>

@ @c
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

@ @c
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

@ @c
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

@ @c
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

@ @c
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

@ @c
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

@ @c
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

@ @c
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

@ @c
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

@ @c
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

@ @c
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

@ @c
void display_push(unsigned int dc) /* FIXME: will it work without `|unsigned|'? */
{
  for (int i = 16; i > 0; i--) { // shift 16 bits out, msb first
    if (dc & 1 << 15) @+ PORTB |= 1 << PB2;
    else @+ PORTB &= ~(1 << PB2);
    PORTB &= ~(1 << PB1); @+ PORTB |= 1 << PB1;
    dc <<= 1;
  }
}

void display_write4(unsigned int dc) /* FIXME: will it work without `|unsigned|'? */
{
  for (int i = 0; i < NUM_DEVICES; i++)
    display_push(dc);
  PORTB |= 1 << PB3; @+ PORTB &= ~(1 << PB3);
}

@ Buffer is necessary because the whole row must be known before outputting it to a given device.

@c
uint8_t buffer[8][NUM_DEVICES*8];

void writeByte(uint8_t byte)
{
  SPDR = byte;                      // SPI starts sending immediately  
  while(!(SPSR & (1 << SPIF)));     // Loop until complete bit set
}

void writeWord(uint8_t address, uint8_t data) 
{
  writeByte(address);
  writeByte(data);
}

@ @c
void display_buffer(void)
{
  for (int i = 0; i < 8; i++) {
    uint8_t data;
    SLAVE_SELECT;
    for (int j = NUM_DEVICES-1; j>=0; j--) {
      data = 0x00;
      for (int k = 0; k < 8; k++) {
        if (buffer[i][j*8+k]) data |= 1 << k;
      }
      writeWord(i+1, data);
    }
    SLAVE_DESELECT;
  }
}

@ @d app_to_buf(chr)
     for (int i = 0; i < sizeof chr / 8; i++) buffer[row][col--] = pgm_read_byte(&chr[row][i])

@c
void fill_buffer(char *s)
{
  for (int row = 0; row < 8; row++) {
    int col = NUM_DEVICES*8-1-1; /* last `|-1|' is the number of padding columns from left
      edge of the whole display */
    char *c = s;
    while (*c != '\0') {
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
      buffer[row][col--] = 0x00; /* empty space; note, that no check for right
        edge of the whole display is done, because due to size of the characters
        we have one free column there */
      c++;
    }
  }
}

void display_MAX(char *s)
{
  fill_buffer(s);
  display_buffer();
}

void main(void)
{
  @<Connect to USB host (must be called first; |sei| is called here)@>@;

  DDRB |= 1 << PB1 | 1 << PB2 | 1 << PB3;

  display_write4(0x0B << 8 | 0x07); /* all characters are used */
  display_write4(0x09 << 8 | 0xFF); /* decode mode */
  display_write4(0x0A << 8 | 0xFF); /* brightness */
  display_write4(0x0C << 8 | 0x01); /* enable */

  while (1) {
    @<If there is a request on |EP0|, handle it@>@;
    UENUM = EP2;
    if (UEINTX & 1 << RXOUTI) {
      UEINTX &= ~(1 << RXOUTI);
      int rx_counter = UEBCLX;
      char s[9];
      int i = 0;
      while (rx_counter--)
        s[i++] = UEDATX;
      s[8] = '\0';
      UEINTX &= ~(1 << FIFOCON);
      if (strcmp(s, "06:00:00") == 0) {
        SLAVE_SELECT;
        for (int i = 0; i < NUM_DEVICES; i++)
          writeWord(0x0A, 0x0F);
        SLAVE_DESELECT;
      }
      if (strcmp(s, "21:00:00") == 0) {
        SLAVE_SELECT;
        for (int i = 0; i < NUM_DEVICES; i++)
          writeWord(0x0A, 0x05);
        SLAVE_DESELECT;
      }
      s[5] = '\0';
      display_MAX(s);
    }
  }
}

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
#include <util/delay.h>

@* Index.
