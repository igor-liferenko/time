\datethis
\input epsf
\input ../usb/USB

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
      char time[8];
      int rx_counter = UEBCLX;
      while (rx_counter--)
        time[7-rx_counter] = UEDATX;
      UEINTX &= ~(1 << FIFOCON);
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

@ No other requests except {\caps set control line state} come
after connection is established. These are sent automatically by the driver when
TTY is opened and closed. We use the close event to blank the display.

See \S6.2.14 in CDC spec.

@<If there is a request on |EP0|, handle it@>=
UENUM = EP0;
if (UEINTX & 1 << RXSTPI) {
  (void) UEDATX; @+ (void) UEDATX;
  int dtr_rts = UEDATX | UEDATX << 8;
  UEINTX &= ~(1 << RXSTPI);
  UEINTX &= ~(1 << TXINI); /* STATUS stage */
  if (!dtr_rts) {
    for (uint8_t row = 0; row < 8; row++)
      for (uint8_t col = 0; col < NUM_DEVICES*8; col++)
        buffer[row][col] = 0x00;
    @<Display buffer@>@;
  }
}

@i ../usb/OUT-endpoint-management.w
@i ../usb/USB.w

@* Headers.

\secpagedepth=1 % index on current page

@<Header files@>=
#include <avr/boot.h> /* |@!boot_signature_byte_get| */
#include <avr/interrupt.h> /* |@!@.ISR@>@t\.{ISR}@>|,
  |@!@.USB\_GEN\_vect@>@t\.{USB\_GEN\_vect}@>|, |@!sei| */
#include <avr/io.h> /* |@!ADDEN|, |@!ALLOC|, |@!DDRB|, |@!DETACH|, |@!EORSTE|, |@!EORSTI|,
  |@!EPDIR|, |@!EPEN|, |@!EPSIZE1|, |@!EPTYPE0|, |@!EPTYPE1|, |@!FIFOCON|, |@!FRZCLK|,
  |@!MCUSR|, |@!MSTR|, |@!OTGPADE|, |@!PB0|, |@!PB1|, |@!PB2|, |@!PB6|, |@!PINDIV|,
  |@!PLLCSR|, |@!PLLE|, |@!PLOCK|, |@!PORTB|, |@!RXOUTI|, |@!RXSTPI|, |@!SPCR|, |@!SPDR|,
  |@!SPE|, |@!SPIF|, |@!SPR1|, |@!SPSR|, |@!STALLRQ|, |@!TXINI|, |@!UDADDR|, |@!UDCON|, |@!UDIEN|,
  |@!UDINT|, |@!UEBCLX|, |@!UECFG0X|, |@!UECFG1X|, |@!UECONX|, |@!UEDATX|, |@!UEINTX|, |@!UENUM|,
  |@!UHWCON|, |@!USBCON|, |@!USBE|, |@!UVREGE|, |@!WDCE|, |@!WDE|, |@!WDRF|, |@!WDTCSR| */
#include <avr/pgmspace.h> /* |@!pgm_read_byte| */
#include <util/delay.h> /* |@!_delay_us| */
