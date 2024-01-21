\datethis
\input epsf

\font\caps=cmcsc10 at 9pt
\font\greek=greekmu % \let\greek=\relax

\secpagedepth=2

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
  @<Setup USB Controller@>@;
  sei();
  UDCON &= ~_BV(DETACH); /* attach after we enabled interrupts, because
    USB\_RESET arrives after attach */

  @<Initialize display@>@;

  while (1) {
    UENUM = 0;
    if (UEINTX & _BV(RXSTPI))
      @<Process CONTROL packet@>@;
    UENUM = 2;
    if (UEINTX & _BV(RXOUTI))
      @<Process OUT packet@>@;
  }
}

@ @<Type definitions@>=
typedef unsigned char U8;
typedef unsigned short U16;

@ @<Process OUT packet@>= {
      UEINTX &= ~_BV(RXOUTI);
      U8 time[8];
      for (U8 c = 0; c < 8; c++)
        time[c] = UEDATX;
      UEINTX &= ~_BV(FIFOCON);
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
PORTB |= _BV(PB0); /* on pro-micro led is inverted */
DDRB |= _BV(PB0); /* disable SPI slave mode (\.{SS} port) */
DDRB |= _BV(PB1); /* clock */
DDRB |= _BV(PB2); /* data */
DDRB |= _BV(PB6); /* latch */
SPCR |= _BV(MSTR) | _BV(SPR1) | _BV(SPE); /* \.{SPR1} means 250 kHz
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
U8 buffer[8][NUM_DEVICES*8];

@ First we assemble the images of received characters in buffer, then we display parts
of buffer corresponding to each device.

@d NUM_DEVICES 4

@<Show |time|@>=
@<Fill buffer@>@;
@<Display buffer@>@;

@ @d app(c) /* append image of specified character to buffer */
for (U8 i = 0; i < sizeof
                               @t}\begingroup\def\vb#1{\\{#1}\endgroup@>@=chr_@>##c / 8; i++)
  buffer[row][col++] = pgm_read_byte(&@t}\begingroup\def\vb#1{\\{#1}\endgroup@>@=chr_@>##c[row][i])

@<Fill buffer@>=
for (U8 row = 0; row < 8; row++) {
  U8 col = 0;
  buffer[row][col++] = 0x00;
  for (U8 *c = time; *c != '\0'; c++) {
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
for (U8 row = 0; row < 8; row++) {
  U8 data;
  for (U8 n = 0; n < NUM_DEVICES; n++) {
    data = 0x00;
    for (U8 i = 0; i < 8; i++)
      if (buffer[row][n*8+i])
        data |= 1 << 7-i;
    display_push(row+1, data);
  }
  PORTB |= _BV(PB6); @+ _delay_us(1); @+ PORTB &= ~_BV(PB6); /* latch */
}

@ @<Functions@>=
void display_push(U8 address, U8 data)
{
  SPDR = address;
  while (!(SPSR & _BV(SPIF))) { }
  SPDR = data;
  while (!(SPSR & _BV(SPIF))) { }
}

@ @<Functions@>=
void display_write4(U8 address, U8 data)
{
  display_push(address, data);
  display_push(address, data);
  display_push(address, data);
  display_push(address, data);
  PORTB |= _BV(PB6); @+ _delay_us(1); @+ PORTB &= ~_BV(PB6); /* latch */
}

@ @<Char...@>=
const U8 chr_0[8][5]
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
const U8 chr_1[8][5]
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
const U8 chr_2[8][5]
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
const U8 chr_3[8][5]
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
const U8 chr_4[8][5]
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
const U8 chr_5[8][5]
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
const U8 chr_6[8][5]
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
const U8 chr_7[8][5]
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
const U8 chr_8[8][5]
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
const U8 chr_9[8][5]
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
const U8 chr_colon[8][6]
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

@* USB setup.

@ \.{USB\_RESET} signal is sent when device is attached and when USB host reboots.

@d EP0_SIZE 64
@d EP0_SIZE_CFG (_BV(EPSIZE0) | _BV(EPSIZE1))

@<Create ISR for USB\_RESET@>=
@.ISR@>@t}\begingroup\def\vb#1{\.{#1}\endgroup@>@=ISR@>
  (@.USB\_GEN\_vect@>@t}\begingroup\def\vb#1{\.{#1}\endgroup@>@=USB_GEN_vect@>)
{
  UDINT &= ~_BV(EORSTI);
  @#
  /* TODO: datasheet section 21.13 says that ep0 can be configured before detach - try to do this
     there instead of in ISR (and/or try to delete `de-configure' lines) */
  UENUM = 0;
  UECONX &= ~_BV(EPEN); /* de-configure */
  UECFG1X &= ~_BV(ALLOC); /* de-configure */
  UECONX |= _BV(EPEN);
  UECFG0X = 0;
  UECFG1X = EP0_SIZE_CFG;
  UECFG1X |= _BV(ALLOC);
  @#
  /* TODO: try to delete the following */
  UENUM = 1;
  UECONX &= ~_BV(EPEN);
  UECFG1X &= ~_BV(ALLOC);
  @#
  UENUM = 2;
  UECONX &= ~_BV(EPEN);
  UECFG1X &= ~_BV(ALLOC);
  @#
  UENUM = 3;
  UECONX &= ~_BV(EPEN);
  UECFG1X &= ~_BV(ALLOC);
  @#
  UENUM = 4;
  UECONX &= ~_BV(EPEN);
  UECFG1X &= ~_BV(ALLOC);
  @#
  UENUM = 5;
  UECONX &= ~_BV(EPEN);
  UECFG1X &= ~_BV(ALLOC);
}

@ @<Setup USB Controller@>=
UHWCON |= _BV(UVREGE);
USBCON |= _BV(USBE);
PLLCSR = _BV(PINDIV);
PLLCSR |= _BV(PLLE);
while (!(PLLCSR & _BV(PLOCK))) { }
USBCON &= ~_BV(FRZCLK);
USBCON |= _BV(OTGPADE);
UDIEN |= _BV(EORSTE);

@* USB connection.

@<Global variables@>=
U16 wValue;
U16 wIndex;
U16 wLength;
U16 size;
const void *buf;

@ @<Process CONTROL packet@>=
switch (UEDATX | UEDATX << 8) { /* Request and Request Type */
case 0x0500: @/
  @<Handle {\caps set address}@>@;
  break;
case 0x0680: @/
  switch (UEDATX | UEDATX << 8) { /* Descriptor Type and Descriptor Index */
  case 0x0100: @/
    @<Handle {\caps get descriptor device}@>@;
    break;
  case 0x0200: @/
    @<Handle {\caps get descriptor configuration}@>@;
    break;
  default: @/
    UECONX |= _BV(STALLRQ);
    UEINTX &= ~_BV(RXSTPI);
  }
  break;
case 0x0900: @/
  @<Handle {\caps set configuration}@>@;
  break;
case 0x2221: @/
  @<Handle {\caps set control line state}@>@;
  break;
default: @/
  UEINTX &= ~_BV(RXSTPI);
  while (!(UEINTX & _BV(RXOUTI))) { }
  UEINTX &= ~_BV(RXOUTI);
  UEINTX &= ~_BV(TXINI);
}

@ @<Handle {\caps set address}@>=
wValue = UEDATX | UEDATX << 8;
UEINTX &= ~_BV(RXSTPI);
UDADDR = wValue;
UEINTX &= ~_BV(TXINI);
while (!(UEINTX & _BV(TXINI))) { } /* see \S22.7 in datasheet */
UDADDR |= _BV(ADDEN);

@ @<Handle {\caps get descriptor device}@>=
(void) UEDATX; @+ (void) UEDATX;
wLength = UEDATX | UEDATX << 8;
UEINTX &= ~_BV(RXSTPI);
buf = &dev_desc; /* 18 bytes */
if (wLength > sizeof dev_desc) size = sizeof dev_desc;
  /* first part of second condition in \S5.5.3 of USB spec */
else size = wLength; /* first condition in \S5.5.3 of USB spec */
while (size) UEDATX = pgm_read_byte(buf++), size--;
UEINTX &= ~_BV(TXINI);
while (!(UEINTX & _BV(RXOUTI))) { }
UEINTX &= ~_BV(RXOUTI);

@ @<Handle {\caps get descriptor configuration}@>=
(void) UEDATX; @+ (void) UEDATX;
wLength = UEDATX | UEDATX << 8;
UEINTX &= ~_BV(RXSTPI);
buf = &conf_desc; /* 86 bytes */
if (wLength > sizeof conf_desc) size = sizeof conf_desc;
  /* first part of second condition in \S5.5.3 of USB spec */
else size = wLength; /* first condition in \S5.5.3 of USB spec */
while (size) {
  while (!(UEINTX & _BV(TXINI))) { }
  for (U8 c = EP0_SIZE; c && size; c--) UEDATX = pgm_read_byte(buf++), size--;
  UEINTX &= ~_BV(TXINI);
}
while (!(UEINTX & _BV(RXOUTI))) { }
UEINTX &= ~_BV(RXOUTI);

@ @<Handle {\caps set configuration}@>=
UEINTX &= ~_BV(RXSTPI);
UEINTX &= ~_BV(TXINI);
@<Configure EP1@>@;
@<Configure EP2@>@;
@<Configure EP3@>@;
@<Configure EP4@>@;
@<Configure EP5@>@;

@ {\caps set control line state} requests are sent automatically by the driver when
TTY is opened and closed.

See \S6.2.14 in CDC spec.

@<Handle {\caps set control line state}@>=
wValue = UEDATX | UEDATX << 8;
UEINTX &= ~_BV(RXSTPI);
UEINTX &= ~_BV(TXINI);
if (wValue == 0) { /* blank the display when TTY is closed */
  for (U8 row = 0; row < 8; row++)
    for (U8 col = 0; col < NUM_DEVICES*8; col++)
      buffer[row][col] = 0x00;
  @<Display buffer@>@;
}

@* USB descriptors.

@*1 Device descriptor.

\S9.6.1 in USB spec; \S4.1, \S5.1.1 in CDC spec.

@<Global variables@>=
struct {
  U8 bLength;
  U8 bDescriptorType;
  U16 bcdUSB;
  U8 bDeviceClass;
  U8 bDeviceSubClass;
  U8 bDeviceProtocol;
  U8 bMaxPacketSize0;
  U16 idVendor;
  U16 idProduct;
  U16 bcdDevice;
  U8 iManufacturer;
  U8 iProduct;
  U8 iSerialNumber;
  U8 bNumConfigurations;
} const dev_desc
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/
  18, @/
  0x01, @/
  0x0200, @/
  0x02, @/
  0, @/
  0, @/
  EP0_SIZE, @/
  0x03EB, @/
  0x2018, @/
  0x1000, @/
  0, @/
  0, @/
  0, @/
@t\2@> 1 @/
};

@*1 Configuration descriptor.

$$\epsfxsize 7cm \epsfbox{usb.eps}$$

@<Global variables@>=
struct {
  @<Configuration header descriptor@>@;
  @<Interface descriptor@>@;
  @<Header functional descriptor@>@;
  @<Abstract Control Management functional descriptor@>@;
  @<Union functional descriptor@>@;
  @<Endpoint descriptor@>@;
  @<Interface descriptor@>@;
  @<Endpoint descriptor@>@;
  @<Endpoint descriptor@>@;
  @<Interface descriptor@>@;
  @<Endpoint descriptor@>@;
  @<Endpoint descriptor@>@;
} const conf_desc
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/
  @<Initialize Configuration header descriptor@>, @/
  @<Initialize Communication Class Interface descriptor@>, @/
  @<Initialize Header functional descriptor@>, @/
  @<Initialize Abstract Control Management functional descriptor@>, @/
  @<Initialize Union functional descriptor@>, @/
  @<Initialize EP5 descriptor@>, @/
  @<Initialize first Data Class Interface descriptor@>, @/
  @<Initialize EP1 descriptor@>, @/
  @<Initialize EP2 descriptor@>, @/
  @<Initialize second Data Class Interface descriptor@>, @/
  @<Initialize EP3 descriptor@>, @/
@t\2@> @<Initialize EP4 descriptor@> @/
};

@*2 Configuration header descriptor.

\S9.6.3 in USB spec.

@<Initialize Configuration header descriptor@>=
CONFIGURATION_HEADER_DESCRIPTOR_SIZE, @/
0x02, @/
CONFIGURATION_HEADER_DESCRIPTOR_SIZE + @/
INTERFACE_DESCRIPTOR_SIZE + @/
HEADER_FUNCTIONAL_DESCRIPTOR_SIZE + @/
ACM_FUNCTIONAL_DESCRIPTOR_SIZE + @/
UNION_FUNCTIONAL_DESCRIPTOR_SIZE + @/
ENDPOINT_DESCRIPTOR_SIZE + @/
INTERFACE_DESCRIPTOR_SIZE + @/
ENDPOINT_DESCRIPTOR_SIZE + @/
ENDPOINT_DESCRIPTOR_SIZE + @/
INTERFACE_DESCRIPTOR_SIZE + @/
ENDPOINT_DESCRIPTOR_SIZE + @/
ENDPOINT_DESCRIPTOR_SIZE, @/
2, @/
1, @/
0, @/
1 << 7, @/
250

@*2 Communication Class Interface descriptor.

\S9.6.5 in USB spec; \S3.3.1, \S4.2, \S4.3, \S4.4 in CDC spec.

@d CONTROL_INTERFACE_NUM 0

@<Initialize Communication Class Interface descriptor@>=
INTERFACE_DESCRIPTOR_SIZE, @/
0x04, @/
CONTROL_INTERFACE_NUM, @/
0, @/
1, @/
0x02, @/
0x02, @/
0x01, @/
0

@*3 Header functional descriptor.

\S5.2.3.1 in CDC spec.

@<Initialize Header functional descriptor@>=
HEADER_FUNCTIONAL_DESCRIPTOR_SIZE, @/
0x24, @/
0x00, @/
0x0110

@*3 Abstract Control Management functional descriptor.

\S5.2.3.3 in CDC spec.

@<Initialize Abstract Control Management functional descriptor@>=
ACM_FUNCTIONAL_DESCRIPTOR_SIZE, @/
0x24, @/
0x02, @/
0

@*3 Union functional descriptor.

\S5.2.3.8 in CDC spec.

@<Initialize Union functional descriptor@>=
UNION_FUNCTIONAL_DESCRIPTOR_SIZE, @/
0x24, @/
0x06, @/
CONTROL_INTERFACE_NUM, @/
DATA_INTERFACE1_NUM, @/
DATA_INTERFACE2_NUM

@*3 EP5 descriptor.

\S9.6.6 in USB spec; \S3.3.1 in CDC spec.

@<Initialize EP5 descriptor@>=
ENDPOINT_DESCRIPTOR_SIZE, @/
0x05, @/
5 | 1 << 7, @/
0x03, @/
8, @/
0xFF

@ @<Configure EP5@>=
UENUM = 5;
UECONX |= _BV(EPEN);
UECFG0X = _BV(EPTYPE0) | _BV(EPTYPE1) | _BV(EPDIR);
UECFG1X = 0;
UECFG1X |= _BV(ALLOC);

@*3 Data Class Interface descriptor.

\S9.6.5 in USB spec; \S3.3.2, \S4.5 in CDC spec.

@d DATA_INTERFACE1_NUM 1

@<Initialize first Data Class Interface descriptor@>=
INTERFACE_DESCRIPTOR_SIZE, @/
0x04, @/
DATA_INTERFACE1_NUM, @/
0, @/
2, @/
0x0A, @/
0x00, @/
0x00, @/
0

@*4 EP1 descriptor.

\S9.6.6 in USB spec; \S3.3.1 in CDC spec.

@<Initialize EP1 descriptor@>=
ENDPOINT_DESCRIPTOR_SIZE, @/
0x05, @/
1 | 1 << 7, @/
0x02, @/
8, @/
0

@ @<Configure EP1@>=
UENUM = 1;
UECONX |= _BV(EPEN);
UECFG0X = _BV(EPTYPE1) | _BV(EPDIR);
UECFG1X = 0;
UECFG1X |= _BV(ALLOC);

@*4 EP2 descriptor.

\S9.6.6 in USB spec; \S3.3.1 in CDC spec.

@<Initialize EP2 descriptor@>=
ENDPOINT_DESCRIPTOR_SIZE, @/
0x05, @/
2 | 0, @/
0x02, @/
8, @/
0

@ @<Configure EP2@>=
UENUM = 2;
UECONX |= _BV(EPEN);
UECFG0X = _BV(EPTYPE1);
UECFG1X = 0;
UECFG1X |= _BV(ALLOC);

@*3 Data Class Interface descriptor.

\S9.6.5 in USB spec; \S3.3.2, \S4.5 in CDC spec.

@d DATA_INTERFACE2_NUM 2

@<Initialize second Data Class Interface descriptor@>=
INTERFACE_DESCRIPTOR_SIZE, @/
0x04, @/
DATA_INTERFACE2_NUM, @/
0, @/
2, @/
0x0A, @/
0x00, @/
0x00, @/
0

@*4 EP3 descriptor.

\S9.6.6 in USB spec; \S3.3.1 in CDC spec.

@<Initialize EP3 descriptor@>=
ENDPOINT_DESCRIPTOR_SIZE, @/
0x05, @/
3 | 1 << 7, @/
0x02, @/
8, @/
0

@ @<Configure EP3@>=
UENUM = 3;
UECONX |= _BV(EPEN);
UECFG0X = _BV(EPTYPE1) | _BV(EPDIR);
UECFG1X = 0;
UECFG1X |= _BV(ALLOC);

@*4 EP4 descriptor.

\S9.6.6 in USB spec; \S3.3.1 in CDC spec.

@<Initialize EP4 descriptor@>=
ENDPOINT_DESCRIPTOR_SIZE, @/
0x05, @/
4 | 0, @/
0x02, @/
8, @/
0

@ @<Configure EP4@>=
UENUM = 4;
UECONX |= _BV(EPEN);
UECFG0X = _BV(EPTYPE1);
UECFG1X = 0;
UECFG1X |= _BV(ALLOC);

@*2 \bf Configuration descriptor headers.

@ Configuration header descriptor.

\S9.6.3 in USB spec.

@d CONFIGURATION_HEADER_DESCRIPTOR_SIZE 9

@<Configuration header descriptor@>=
U8 bLength;
U8 bDescriptorType;
U16 wTotalLength;
U8 bNumInterfaces;
U8 bConfigurationValue;
U8 iConfiguration;
U8 bmAttibutes;
U8 MaxPower;

@ Interface descriptor.

\S9.6.5 in USB spec.

@d INTERFACE_DESCRIPTOR_SIZE 9

@<Interface descriptor@>=
U8 bLength;
U8 bDescriptorType;
U8 bInterfaceNumber;
U8 bAlternativeSetting;
U8 bNumEndpoints;
U8 bInterfaceClass;
U8 bInterfaceSubClass;
U8 bInterfaceProtocol;
U8 iInterface;

@ Header functional descriptor.

\S5.2.3.1 in CDC spec.

@d HEADER_FUNCTIONAL_DESCRIPTOR_SIZE 5

@<Header functional descriptor@>=
U8 bFunctionLength;
U8 bDescriptorType;
U8 bDescriptorSubtype;
U16 bcdCDC;

@ Abstract Control Management functional descriptor.

\S5.2.3.3 in CDC spec.

@d ACM_FUNCTIONAL_DESCRIPTOR_SIZE 4

@<Abstract Control Management functional descriptor@>=
U8 bFunctionLength;
U8 bDescriptorType;
U8 bDescriptorSubtype;
U8 bmCapabilities;

@ Union functional descriptor.

\S5.2.3.8 in CDC spec.

@d UNION_FUNCTIONAL_DESCRIPTOR_SIZE 6

@<Union functional descriptor@>=
U8 bFunctionLength;
U8 bDescriptorType;
U8 bDescriptorSubtype;
U8 bMasterInterface;
U8 bSlaveInterface0;
U8 bSlaveInterface1;

@ Endpoint descriptor.

\S9.6.6 in USB spec.

@d ENDPOINT_DESCRIPTOR_SIZE 7

@<Endpoint descriptor@>=
U8 bLength;
U8 bDescriptorType;
U8 bEndpointAddress;
U8 bmAttributes;
U16 wMaxPacketSize;
U8 bInterval;

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
