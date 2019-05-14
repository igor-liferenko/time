\let\lheader\rheader
%\datethis

\input USB

@* Program.

$$\hbox to7cm{\vbox to5.82cm{\vfil\special{psfile=max4.eps
  clip llx=0 lly=0 urx=179 ury=149 rwi=1984}}\hfil}$$

$$\hbox to7.16cm{\vbox to2.99861111111111cm{\vfil\special{psfile=time.1
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
      char time[9];
      int rx_counter = UEBCLX;
      while (rx_counter--)
        time[7-rx_counter] = UEDATX;
      UEINTX &= ~(1 << FIFOCON);
      time[8] = '\0';
      @<Set brightness depending on time of day@>@;
      time[5] = '\0';
      @<Show |time|@>@;
    }
  }
}

@ Initialization of all registers must be done, because they may contain garbage.
First make sure that test mode is disabled, because it overrides all registers.
Next, make sure that display is disabled, because there may be random lighting LEDs on it.
Then set decode mode to properly clear all LEDs,
and clear them. Finally, configure the rest registers and enable the display.

Note, that |PB0| must be set to OUTPUT for SPI master.
On pro-micro it has a LED attached to it.

SPI here is used as a way to push bytes to display (data + clock).
Latch is used only in the end, like in shift registers.
Frequency of SPI clock is adjusted empirically (starting from highest).
Latch duration which should be safe is 1$\mu$s (minimum is 50ns according to datasheet).
It can also be adjusted, but after frequency - use NOP's to decrease it.
Take into accound capacitance of wires for SPI - signal may raise and fall with some latency
(clock and latch are in parallel, DIN goes through each device to DOUT and then to DIN of
next device in a chain).

@<Initialize display@>=
PORTB |= 1 << PB0; /* on pro-micro led is inverted */
DDRB |= 1 << PB0 | 1 << PB1 | 1 << PB2 | 1 << PB6;
SPCR |= 1 << MSTR | 1 << SPR1 | 1 << SPE; /* \.{SPR1} means 250 kHz */
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

@ Buffer is used because in each device addresses are assigned to rows.

@d NUM_DEVICES 4

@<Show |time|@>=
uint8_t buffer[8][NUM_DEVICES*8];
@<Fill buffer@>@;
@<Display buffer@>@;

@ @d app(c) /* append specified character to buffer */
     for (uint8_t i = 0; i < sizeof chr_##c / 8; i++)
       buffer[row][col++] = pgm_read_byte(&chr_##c[row][i])

@<Fill buffer@>=
for (uint8_t row = 0; row < 8; row++) {
  uint8_t col = 0;
  buffer[row][col++] = 0x00;
  for (char *c = time; *c != '\0'; c++) {
    switch (*c)
    {
    case '0': app(0); @+ break;
    case '1': app(1); @+ break;
    case '2': app(2); @+ break;
    case '3': app(3); @+ break;
    case '4': app(4); @+ break;
    case '5': app(5); @+ break;
    case '6': app(6); @+ break;
    case '7': app(7); @+ break;
    case '8': app(8); @+ break;
    case '9': app(9); @+ break;
    case ':': app(colon);
    }
    buffer[row][col++] = 0x00;
  }
}

@ Rows are output from right to left, from top to bottom.
Left device is set first, right device is set last.

$$\hbox to8.89cm{\vbox to2.04611111111111cm{\vfil\special{psfile=time.2
  clip llx=-39 lly=-26 urx=213 ury=32 rwi=2520}}\hfil}$$

@<Display buffer@>=
for (uint8_t row = 0; row < 8; row++) {
  uint8_t data;
  for (uint8_t n = 0; n < NUM_DEVICES; n++) {
    data = 0x00;
    for (uint8_t i = 0; i < 8; i++)
      if (buffer[row][n*8+i])
        data |= 1 << 7-i;
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
  display_push(address, data);
  display_push(address, data);
  display_push(address, data);
  display_push(address, data);
  PORTB |= 1 << PB6; @+ _delay_us(1); @+ PORTB &= ~(1 << PB6);
}

@ @<Global variables@>=
@<Character images@>@;

@ @<Char...@>=
const uint8_t chr_0[8][5]
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
const uint8_t chr_1[8][5]
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
const uint8_t chr_2[8][5]
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
const uint8_t chr_3[8][5]
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
const uint8_t chr_4[8][5]
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
const uint8_t chr_5[8][5]
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
const uint8_t chr_6[8][5]
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
const uint8_t chr_7[8][5]
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
const uint8_t chr_8[8][5]
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
const uint8_t chr_9[8][5]
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
const uint8_t chr_colon[8][6]
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

@ This code takes approx ? ms (SPI speed is 250kHz), so it has enough time
to complete until new time is sent from USB host.
FIXME: instead of counting time interval that this code takes, device a test
method via led or something to see this objectively

@<Set brightness...@>=
if (strcmp(time, "21:00:00") >= 0 || strcmp(time, "06:00:00") < 0) display_write4(0x0A, 0x01);
if (strcmp(time, "06:00:00") >= 0 && strcmp(time, "21:00:00") < 0) display_write4(0x0A, 0x0F);

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
