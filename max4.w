\let\lheader\rheader
%\datethis
\secpagedepth=2 % begin new page only on *
\font\caps=cmcsc10 at 9pt

@* Program.

NOTE: working is last commit on 2019-03-31; TODO: do via bitbang like in max.w

$$\hbox to7cm{\vbox to5.82cm{\vfil\special{psfile=max4-pic.eps
  clip llx=0 lly=0 urx=179 ury=149 rwi=1984}}\hfil}$$

$$\hbox to10.26cm{\vbox to5.46805555555556cm{\vfil\special{psfile=MAX.1
  clip llx=-85 lly=-38 urx=206 ury=117 rwi=2910}}\hfil}$$

Displaying is done in rows (i.e., row address is used in show command), from top row to bottom row.
On each display each row is set from right to left.
Left device is set first, right device is set last.

$$\hbox to4.23cm{\vbox to1.05833333333333cm{\vfil\special{psfile=max4.1
  clip llx=-12 lly=-12 urx=108 ury=18 rwi=1200}}\hfil}$$

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

@ @d digit_0_width 5

@c
const uint8_t digit_0[8][digit_0_width]
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

@ @d digit_1_width 5

@c
const uint8_t d1[8][digit_1_width] PROGMEM = {
  { 0, 0, 1, 0, 0 },
  { 0, 1, 1, 0, 0 },
  { 0, 0, 1, 0, 0 },
  { 0, 0, 1, 0, 0 },
  { 0, 0, 1, 0, 0 },
  { 0, 0, 1, 0 ,0 },
  { 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0 }
};

@ @d digit_2_width 5

@c
const uint8_t digit_2[8][digit_2_width] PROGMEM = {
  { 0, 1, 1, 1, 0 },
  { 1, 0, 0, 0, 1 },
  { 0, 0, 0, 0, 1 },
  { 0, 0, 0, 1, 0 },
  { 0, 0, 1, 0, 0 },
  { 0, 1, 0, 0, 0 },
  { 1, 1, 1, 1, 1 },
  { 0, 0, 0, 0, 0 }
};

@ @d digit_3_width 5

@c
const uint8_t digit_3[8][digit_3_width] PROGMEM = {
  { 1, 1, 1, 1, 1 },
  { 0, 0, 0, 1, 0 },
  { 0, 0, 1, 0, 0 },
  { 0, 0, 0, 1, 0 },
  { 0, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 1 },
  { 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0 }
};

@ @c
const uint8_t d4[8][5] PROGMEM = {
  { 0, 0, 0, 1, 0 },
  { 0, 0, 1, 1, 0 },
  { 0, 1, 0, 1, 0 },
  { 1, 0, 0, 1, 0 },
  { 1, 1, 1, 1, 1 },
  { 0, 0, 0, 1, 0 },
  { 0, 0, 0, 1, 0 },
  { 0, 0, 0, 0, 0 }
};

const uint8_t d5[8][5] PROGMEM = {
  { 1, 1, 1, 1, 1 },
  { 1, 0, 0, 0, 0 },
  { 1, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 1 },
  { 0, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 1 },
  { 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0 }
};

const uint8_t d6[8][5] PROGMEM = {
  { 0, 0, 1, 1, 0 },
  { 0, 1, 0, 0, 0 },
  { 1, 0, 0, 0, 0 },
  { 1, 1, 1, 1, 0 },
  { 1, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 1 },
  { 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0 }
};

const uint8_t d7[8][5] PROGMEM = {
  { 1, 1, 1, 1, 1 },
  { 1, 0, 0, 0, 1 },
  { 0, 0, 0, 1, 0 },
  { 0, 0, 1, 0, 0 },
  { 0, 1, 0, 0, 0 },
  { 0, 1, 0, 0, 0 },
  { 0, 1, 0, 0, 0 },
  { 0, 0, 0, 0, 0 }
};

const uint8_t d8[8][5] PROGMEM = {
  { 0, 1, 1, 1, 0 },
  { 1, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 1 },
  { 0, 1, 1, 1, 0 },
  { 1, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 1 },
  { 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0 }
};

const uint8_t d9[8][5] PROGMEM = {
  { 0, 1, 1, 1, 0 },
  { 1, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 1 },
  { 0, 1, 1, 1, 1 },
  { 0, 0, 0, 0, 1 },
  { 0, 0, 0, 1, 0 },
  { 0, 1, 1, 0, 0 },
  { 0, 0, 0, 0, 0 }
};

@ @d colon_width 6

@c
const uint8_t colon[8][colon_width] PROGMEM = {
  { 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0 },
  { 0, 0, 1, 1, 0, 0 },
  { 0, 0, 1, 1, 0, 0 },
  { 0, 0, 0, 0, 0, 0 },
  { 0, 0, 1, 1, 0, 0 },
  { 0, 0, 1, 1, 0, 0 },
  { 0, 0, 0, 0, 0, 0 }
};

@ Buffer is necessary because <see paper with notes>.

@c
uint8_t buffer[8][NUM_DEVICES*8];

void init_SPI(void) 
{
  DDRB |= 1 << PB0; /* this pin is not used for SS because it is not available on promicro,
    but it must be set for OUTPUT anyway, otherwise MCU will be used as SPI slave;
    and on micro board which has SS pin it should not be used anyway because LED is
    attached to it, which means it will be almost constantly ON (i.e., when SPI is
    inactive) */
  DDRB |= 1 << PB3;
  PORTB |= 1 << PB3;      // begin high (unselected)

  DDRB |= (1 << PB2);       // Output on MOSI 
  DDRB |= (1 << PB1);       // Output on SCK 

  SPCR |= (1 << MSTR);      // Clockmaster 
  SPCR |= (1 << SPE);       // Enable SPI
  // this means that SCK frequency is default clk/4, i.e., 4MHz
}

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

void init_displays(void)
{
  SLAVE_SELECT;
  for (int i = 0; i < NUM_DEVICES; i++)
    writeWord(0x0A, 0x0F); // brightness
  SLAVE_DESELECT;

  SLAVE_SELECT;
  for (int i = 0; i < NUM_DEVICES; i++)
    writeWord(0x0B, 0x07); /* all rows are used */
  SLAVE_DESELECT;

  SLAVE_SELECT;
  for (int i = 0; i < NUM_DEVICES; i++)
    writeWord(0x0C, 0x01);
  SLAVE_DESELECT;
}

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

@ Append character to buffer.

@d app_char(buf, width) for (int j = 0; j < width; j++) buffer[i][k--] = pgm_read_byte(&buf[i][j]);

@c
void fill_buffer(char *s)
{
  for (int i = 0; i < 8; i++) {
    int k = NUM_DEVICES*8-1-1; /* last `|-1|' is the number of padding columns from left
      edge of the whole display */
    for (int c = 0; c < strlen(s); c++) {
      switch (*(s+c))
      {
      case '0':
        app_char(digit_0, digit_0_width);
        break;
      case '1':
        app_char(digit_1, digit_1_width);
        break;
      case '2':
        app_char(digit_2, digit_2_width);
        break;
      case '3':
        app_char(digit_3, digit_3_width);
        break;
      case '4':
        app_char(digit_4,5);
        break;
      case '5':
        app_char(digit_5,5);
        break;
      case '6':
        app_char(digit_6,5);
        break;
      case '7':
        app_char(digit_7,5);
        break;
      case '8':
        app_char(digit_8,5);
        break;
      case '9':
        app_char(digit_9,5);
        break;
      case ':':
        app_char(colon, colon_width);
        break;
      }
      buffer[i][k--] = 0x00; /* empty space; note, that no check for right
        edge of the whole display is done, because due to size of the characters
        we have one free column there */
    } // end char
  } // end row
}

void init_MAX(void)
{
  init_SPI();
  init_displays();
}

void display_MAX(char *s)
{
  fill_buffer(s);
  display_buffer();
}

void main(void)
{
  @<Connect to USB host (must be called first; |sei| is called here)@>@;
  init_MAX();
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
