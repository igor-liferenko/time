\let\lheader\rheader
%\datethis
\secpagedepth=2 % begin new page only on *
\font\caps=cmcsc10 at 9pt

@* Program.

$$\hbox to7cm{\vbox to5.82cm{\vfil\special{psfile=max4-1.eps
  clip llx=0 lly=0 urx=179 ury=149 rwi=1984}}\hfil}$$
$$\hbox to7cm{\vbox to5.96cm{\vfil\special{psfile=max4-2.eps
  clip llx=0 lly=0 urx=175 ury=149 rwi=1984}}\hfil}$$
$$\hbox to7cm{\vbox to6.53cm{\vfil\special{psfile=max4-3.eps
  clip llx=0 lly=0 urx=181 ury=169 rwi=1984}}\hfil}$$

$$\hbox to10.26cm{\vbox to5.46805555555556cm{\vfil\special{psfile=MAX.1
  clip llx=-85 lly=-38 urx=206 ury=117 rwi=2910}}\hfil}$$

@c
@<Header files@>@;
@<Type definitions@>@;
@<Global variables@>@;
@<Create ISR for connecting to USB host@>@;

/* Displaying for each display is done by writing to its row address (not column) due
to configuration of this pacrticular hardware that I have. */

/* displaying is done in rows, from top row to bottom row, from left display to right display,
   from right to left on each display TODO: draw figure via boxes.mp */

#define NUM_DEVICES 4

#define SLAVE_SELECT    PORTB &= ~(1 << PB3)
#define SLAVE_DESELECT  PORTB |= 1 << PB3

#include <avr/io.h>
#include <avr/pgmspace.h>
#include <string.h>

@ @c
const uint8_t d0[8][5] PROGMEM = { 
  { 0, 1, 1, 1, 0 },
  { 1, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 1 },
  { 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0 }
};

@ @c
const uint8_t d1[8][5] PROGMEM = {
  { 0, 0, 1, 0, 0 },
  { 0, 1, 1, 0, 0 },
  { 0, 0, 1, 0, 0 },
  { 0, 0, 1, 0, 0 },
  { 0, 0, 1, 0, 0 },
  { 0, 0, 1, 0 ,0 },
  { 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0 }
};

@ @c
const uint8_t d2[8][5] PROGMEM = {
  { 0, 1, 1, 1, 0 },
  { 1, 0, 0, 0, 1 },
  { 0, 0, 0, 0, 1 },
  { 0, 0, 0, 1, 0 },
  { 0, 0, 1, 0, 0 },
  { 0, 1, 0, 0, 0 },
  { 1, 1, 1, 1, 1 },
  { 0, 0, 0, 0, 0 }
};

@ @c
const uint8_t d3[8][5] PROGMEM = {
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

@ @c
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

@ @c
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

@ @c
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

@ @c
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

@ @c
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

@ @c
const uint8_t colon[8][5] PROGMEM = {
  { 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0 },
  { 0, 0, 1, 1, 0 },
  { 0, 0, 1, 1, 0 },
  { 0, 0, 0, 0, 0 },
  { 0, 0, 1, 1, 0 },
  { 0, 0, 1, 1, 0 },
  { 0, 0, 0, 0, 0 }
};

@ @c
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

/* TODO: put delay between |SLAVE_DESELECT| and |SLAVE_SELECT| here and
at the end of |init_MAX| and after setting brightness in main cycle - see
https://electronics.stackexchange.com/questions/430442/how-to-interpret-max7219-timing-diagram
*/

void init_displays(void)
{
  SLAVE_SELECT;
  for (int i = 0; i < NUM_DEVICES; i++)
    writeWord(0x0A, 0x0F); // brightness
  SLAVE_DESELECT;

  SLAVE_SELECT;
  for (int i = 0; i < NUM_DEVICES; i++)
    writeWord(0x0B, 0x07); /* bits in byte corresponding to each of 8 addresses for each display
      govern the 8 leds corresponding to address */
  SLAVE_DESELECT;

  SLAVE_SELECT;
  for (int i = 0; i < NUM_DEVICES; i++)
    writeWord(0x0F, 0x00); /* without it it does not work after plug (but works after flash)
      FIXME: see datasheet for explanation of this command */
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

#define CYC(b) for (int j = 0; j < 5; j++) buffer[i][k--] = pgm_read_byte(&b[i][j]);
void fill_buffer(char *s)
{
  for (int i = 0; i < 8; i++) {
    int k = NUM_DEVICES*8-1-2;
    for (int c = 0; c < strlen(s); c++) {
      switch (*(s+c))
      {
      case '0':
        CYC(d0);
        break;
      case '1':
        CYC(d1);
        break;
      case '2':
        CYC(d2);
        break;
      case '3':
        CYC(d3);
        break;
      case '4':
        CYC(d4);
        break;
      case '5':
        CYC(d5);
        break;
      case '6':
        CYC(d6);
        break;
      case '7':
        CYC(d7);
        break;
      case '8':
        CYC(d8);
        break;
      case '9':
        CYC(d9);
        break;
      case ':':
        CYC(colon);
        break;
      }
      buffer[i][k--] = 0x00; // empty space
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
      s[5] = '\0';
      UEINTX &= ~(1 << FIFOCON);
      if (strcmp(s,"06:00")==0) {
        SLAVE_SELECT;
        for (int i = 0; i < NUM_DEVICES; i++)
          writeWord(0x0A, 0x0F);
        SLAVE_DESELECT;
      }
      if (strcmp(s,"21:00")==0) {
        SLAVE_SELECT;
        for (int i = 0; i < NUM_DEVICES; i++)
          writeWord(0x0A, 0x05);
        SLAVE_DESELECT;
      }
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

@* Index.
