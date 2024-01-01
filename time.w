% TODO: change `1 << BIT' to `_BV(BIT)'
% TODO: delete serial from USB.w and debug.ch
% TODO: delete `/* 18 bytes\footnote... */'
% TODO: move from USB.w to this file

\datethis
\input epsf
\input USB

@s uint8_t int

@* Program. Display time from USB using MAX7219 module.

$$\epsfbox{max4.eps}$$

$$\epsfbox{arduino.eps}$$

@c
@<Header files@>@;
@<Type definitions@>@;
@<Global variables@>@;
@<Character images@>@;
@<Functions@>@;
@<Create ISR...@>@;

void main(void)
{
  @<Fill in |sn_desc| with serial number@>@;
  @<Setup USB Controller@>@;
  sei();
  UDCON &= ~(1 << DETACH); /* attach after we enabled interrupts, because
    USB\_RESET arrives after attach */

  @<Initialize display@>@;

  while (1) {
    UENUM = 0;
    if (UEINTX & 1 << RXSTPI)
      @<Process CONTROL packet@>@;
    UENUM = 2;
    if (UEINTX & 1 << RXOUTI)
      @<Process OUT packet@>@;
  }
}

@ @<Process OUT packet@>= {
      UEINTX &= ~(1 << RXOUTI);
      char time[8];
      int rx_counter = UEBCLX;
      while (rx_counter--)
        time[7-rx_counter] = UEDATX;
      UEINTX &= ~(1 << FIFOCON);
      if (time[0] == 'A') {
        display_write4(0x0A, time[1]); /* set brightness */
        continue;
      }
      time[5] = '\0';
      @<Show |time|@>@;
    }

@ Initialization of all registers must be done, because they may contain garbage.
First make sure that test mode is disabled, because it overrides all registers.
Next, make sure that display is disabled, because there may be random lighting LEDs on it.
Then set decode mode to properly clear all LEDs,
and clear them. Finally, configure the rest registers and enable the display.

MAX7219 is a shift register.
SPI here is used as a way to push bytes to MAX7219 (data + clock).

For simplicity (not to use timer), we use latch duration of 1{\greek u}s (min.\ is
50ns---t\lower.25ex\hbox{\the\scriptfont0 CSW} in datasheet).

Note, that segments are connected as this: clock and latch are in parallel,
DIN goes through each segment to DOUT and then to DIN of next segment in the chain.

@<Initialize display@>=
PORTB |= 1 << PB0; /* on pro-micro led is inverted */
DDRB |= 1 << PB0; /* disable SPI slave mode (\.{SS} port) */
DDRB |= 1 << PB1; /* clock */
DDRB |= 1 << PB2; /* data */
DDRB |= 1 << PB6; /* latch */
SPCR |= 1 << MSTR | 1 << SPR1 | 1 << SPE; /* \.{SPR1} means 250 kHz
  FIXME: does native wire work without SPR1? does long wire work without SPR1? */
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

@ @<Global variables@>=
uint8_t buffer[8][NUM_DEVICES*8];

@ First we assemble the images of received characters in buffer, then we display parts
of buffer corresponding to each device.

@d NUM_DEVICES 4

@<Show |time|@>=
@<Fill buffer@>@;
@<Display buffer@>@;

@ @d app(c) /* append image of specified character to buffer */
for (uint8_t i = 0; i < sizeof
                               @t}\begingroup\def\vb#1{\\{#1}\endgroup@>@=chr_@>##c / 8; i++)
  buffer[row][col++] = pgm_read_byte(&@t}\begingroup\def\vb#1{\\{#1}\endgroup@>@=chr_@>##c[row][i])

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
    case ':': app(@t}\begingroup\def\vb#1{\\{#1}\endgroup@>@=colon@>);
    }
    buffer[row][col++] = 0x00;
  }
}

@ Rows are output from right to left, from top to bottom.
Left device is set first, right device is set last.

$$\epsfbox{time.eps}$$

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
  PORTB |= 1 << PB6; @+ _delay_us(1); @+ PORTB &= ~(1 << PB6); /* latch */
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
  PORTB |= 1 << PB6; @+ _delay_us(1); @+ PORTB &= ~(1 << PB6); /* latch */
}

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

@i USB.w

@* Headers.

\halign{\.{#}\hfil&#\hfil\cr
\noalign{\kern10pt}
%
EORSTE  & End Of Reset Interrupt Enable \cr
EORSTI  & End Of Reset Interrupt \cr
\noalign{\medskip}
FIFOCON & FIFO Control \cr
PLLCSR  & PLL Control and Status Register \cr
RXOUTI  & Received OUT Interrupt \cr
RXSTPI  & Received SETUP Interrupt \cr
\noalign{\medskip}
UDIEN   & USB Device Interrupt Enable \cr
UDINT   & USB Device Interrupt \cr
\noalign{\medskip}
UECFG1X & USB Endpoint-X Configuration 1 \cr
UEDATX  & USB Endpoint-X Data \cr
\noalign{\medskip}
UEIENX  & USB Endpoint-X Interrupt Enable \cr
UEINTX  & USB Endpoint-X Interrupt \cr
\noalign{\medskip}
UENUM   & USB endpoint number \cr
USBCON  & USB Control \cr
USBINT  & USB General Interrupt \cr
%
\noalign{\kern10pt}}

@<Header files@>=
#include <avr/boot.h>
#include <avr/interrupt.h>
#include <avr/io.h>
#include <avr/pgmspace.h>
#include <util/delay.h>
