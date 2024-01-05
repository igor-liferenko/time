\datethis
\input epsf

\font\caps=cmcsc10 at 9pt
\font\greek=greekmu % \let\greek=\relax

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
      U8 rx_counter = UEBCLX;
      while (rx_counter--)
        time[7-rx_counter] = UEDATX;
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

@* Establishing USB connection.

@ \.{USB\_RESET} signal is sent when device is attached and when USB host reboots.

TODO: datasheet section 21.13 says that ep0 can be configured before detach - try to do this
there instead of in ISR

@d EP0_SIZE 64

@<Create ISR for USB\_RESET@>=
@.ISR@>@t}\begingroup\def\vb#1{\.{#1}\endgroup@>@=ISR@>
  (@.USB\_GEN\_vect@>@t}\begingroup\def\vb#1{\.{#1}\endgroup@>@=USB_GEN_vect@>)
{
  UDINT &= ~_BV(EORSTI);
  @#
  UENUM = 0;
  UECONX &= ~_BV(EPEN);
  UECFG1X &= ~_BV(ALLOC);
  UECONX |= _BV(EPEN);
  UECFG0X = 0;
  UECFG1X = _BV(EPSIZE0) | _BV(EPSIZE1); /* 64 bytes\footnote\ddag{Must correspond to |EP0_SIZE|.} */
  UECFG1X |= _BV(ALLOC);
  @#
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

@* Connection protocol.

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
UEINTX &= ~_BV(TXINI);
UDADDR = wValue & 0x7f;
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
buf = &conf_desc; /* 62 bytes */
if (wLength > sizeof conf_desc) size = sizeof conf_desc;
  /* first part of second condition in \S5.5.3 of USB spec */
else size = wLength; /* first condition in \S5.5.3 of USB spec */
while (size) UEDATX = pgm_read_byte(buf++), size--;
UEINTX &= ~_BV(TXINI);
while (!(UEINTX & _BV(RXOUTI))) { }
UEINTX &= ~_BV(RXOUTI);

@ Endpoint 3 (interrupt IN) is not used, but it must be present (for more info
see ``Communication Class notification endpoint notice'' in index).

@d EP1_SIZE 8
@d EP2_SIZE 8
@d EP3_SIZE 8

@<Handle {\caps set configuration}@>=
UEINTX &= ~_BV(RXSTPI);
UEINTX &= ~_BV(TXINI);
@#
UENUM = 1;
UECONX |= _BV(EPEN);
UECFG0X = _BV(EPTYPE1) | _BV(EPDIR); /* bulk\footnote\dag{Must
  correspond to |@<Initialize element 8 ...@>|.}, IN */
UECFG1X = 0; /* 8 bytes\footnote\ddag{Must correspond to |EP1_SIZE|.} */
UECFG1X |= _BV(ALLOC);
@#
UENUM = 2;
UECONX |= _BV(EPEN);
UECFG0X = _BV(EPTYPE1); /* bulk\footnote\dag{Must
  correspond to |@<Initialize element 9 ...@>|.}, OUT */
UECFG1X = 0; /* 8 bytes\footnote\ddag{Must correspond to |EP2_SIZE|.} */
UECFG1X |= _BV(ALLOC);
@#
UENUM = 3;
UECONX |= _BV(EPEN);
UECFG0X = _BV(EPTYPE1) | _BV(EPTYPE0) | _BV(EPDIR); /* interrupt\footnote\dag{Must
  correspond to |@<Initialize element 6 ...@>|.}, IN */
UECFG1X = 0; /* 8 bytes\footnote\ddag{Must correspond to |EP3_SIZE|.} */
UECFG1X |= _BV(ALLOC);

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

Placeholder prefixes such as `b', `bcd', and `w' are used to denote placeholder type:

\noindent\hskip40pt\hbox to0pt{\hskip-20pt\it b\hfil} bits or bytes; dependent on context \par
\noindent\hskip40pt\hbox to0pt{\hskip-20pt\it bcd\hfil} binary-coded decimal \par
\noindent\hskip40pt\hbox to0pt{\hskip-20pt\it bm\hfil} bitmap \par
\noindent\hskip40pt\hbox to0pt{\hskip-20pt\it d\hfil} descriptor \par
\noindent\hskip40pt\hbox to0pt{\hskip-20pt\it i\hfil} index \par
\noindent\hskip40pt\hbox to0pt{\hskip-20pt\it w\hfil} word \par

@<Global variables@>=
struct {
  U8 bLength;
  U8 bDescriptorType;
  U16 bcdUSB; /* version */
  U8 bDeviceClass; /* class code assigned by the USB */
  U8 bDeviceSubClass; /* sub-class code assigned by the USB */
  U8 bDeviceProtocol; /* protocol code assigned by the USB */
  U8 bMaxPacketSize0; /* max packet size for EP0 */
  U16 idVendor;
  U16 idProduct;
  U16 bcdDevice; /* device release number */
  U8 iManufacturer; /* index of manu. string descriptor */
  U8 iProduct; /* index of prod. string descriptor */
  U8 iSerialNumber; /* index of S.N. string descriptor */
  U8 bNumConfigurations;
} const dev_desc
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/
  18, /* size of this structure */
  0x01, /* device */
  0x0200, /* USB 2.0 */
  0x02, /* CDC (\S4.1 in CDC spec) */
  0, /* no subclass */
  0, @/
  EP0_SIZE, @/
  0x03EB, /* VID (Atmel) */
  0x2018, /* PID (CDC ACM) */
  0x1000, /* device revision */
  0, /* no manufacturer */
  0, /* no product */
  0, /* no serial number */
@t\2@> 1 /* one configuration for this device */
};

@*1 Configuration descriptor.

Abstract Control Model consists of two interfaces: Data Class interface
and Communication Class interface.

The Communication Class interface uses two endpoints\footnote*{Although
CDC spec says that notification endpoint is optional, in Linux host
driver refuses to work without it. Besides, notifocation endpoint (EP3) can
be used for DSR signal.},
@^Communication Class notification endpoint notice@>
one to implement a notification element and the other to implement
a management element. The management element uses the default endpoint
for all standard and Communication Class-specific requests.

Theh Data Class interface consists of two endpoints to implement
channels over which to carry data.

\S3.4 in CDC spec.

$$\epsfxsize 7cm \epsfbox{usb.eps}$$

@<Type definitions@>=
@<Type definition{s} used in configuration descriptor@>@;
typedef struct {
  @<Configuration header descriptor@> @,@,@! el1;
  S_interface_descriptor el2;
  @<Class-specific interface descriptor 1@> @,@,@! el3;
  @<Class-specific interface descriptor 2@> @,@,@! el5;
  @<Class-specific interface descriptor 3@> @,@,@! el6;
  S_endpoint_descriptor el7;
  S_interface_descriptor el8;
  S_endpoint_descriptor el9;
  S_endpoint_descriptor el10;
} S_configuration_descriptor;

@ @<Global variables@>=
const S_configuration_descriptor conf_desc
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/
  @<Initialize element 1 ...@>, @/
  @<Initialize element 2 ...@>, @/
  @<Initialize element 3 ...@>, @/
  @<Initialize element 4 ...@>, @/
  @<Initialize element 5 ...@>, @/
  @<Initialize element 6 ...@>, @/
  @<Initialize element 7 ...@>, @/
  @<Initialize element 8 ...@>, @/
@t\2@> @<Initialize element 9 ...@> @/
};

@*2 Configuration header descriptor.

@ @<Configuration header descriptor@>=
struct {
   U8 bLength;
   U8 bDescriptorType;
   U16 wTotalLength;
   U8 bNumInterfaces;
   U8 bConfigurationValue; /* number between 1 and |bNumConfigurations|, for
     each configuration\footnote\dag{For some reason
     configurations start numbering with `1', and interfaces and altsettings with `0'.} */
   U8 iConfiguration; /* index of string descriptor */
   U8 bmAttibutes;
   U8 MaxPower;
}

@ @<Initialize element 1 in configuration descriptor@>= { @t\1@> @/
  9, /* size of this structure */
  0x02, /* configuration descriptor */
  sizeof (S_configuration_descriptor), @/
  2, /* two interfaces in this configuration */
  1, /* this corresponds to `1' in `cfg1' on picture */
  0, /* no string descriptor */
  0x80, /* device is powered from bus */
@t\2@> 0x32 /* device uses 100mA */
}

@*2 Interface descriptor.

@s S_interface_descriptor int

@<Type definition{s} ...@>=
typedef struct {
   U8 bLength;
   U8 bDescriptorType;
   U8 bInterfaceNumber; /* number between 0 and |bNumInterfaces-1|, for
                                     each interface */
   U8 bAlternativeSetting; /* number starting from 0, for each interface */
   U8 bNumEndpoints; /* number of EP except EP 0 */
   U8 bInterfaceClass; /* class code assigned by the USB */
   U8 bInterfaceSubClass; /* sub-class code assigned by the USB */
   U8 bInterfaceProtocol; /* protocol code assigned by the USB */
   U8 iInterface; /* index of string descriptor */
}  S_interface_descriptor;

@ @<Initialize element 2 in configuration descriptor@>= { @t\1@> @/
  9, /* size of this structure */
  0x04, /* interface descriptor */
  0, /* this corresponds to `0' in `if0' on picture */
  0, /* this corresponds to `0' in `alt0' on picture */
  1, /* one endpoint is used */
  0x02, /* CDC (\S4.2 in CDC spec) */
  0x02, /* ACM (\S4.3 in CDC spec) */
  0x01, /* AT command (\S4.4 in CDC spec) */
@t\2@> 0 /* not used */
}

@ @<Initialize element 7 in configuration descriptor@>= { @t\1@> @/
  9, /* size of this structure */
  0x04, /* interface descriptor */
  1, /* this corresponds to `1' in `if1' on picture */
  0, /* this corresponds to `0' in `alt0' on picture */
  2, /* two endpoints are used */
  0x0A, /* CDC data (\S4.5 in CDC spec) */
  0x00, /* unused */
  0x00, /* no protocol */
@t\2@> 0 /* not used */
}

@*2 Endpoint descriptor.

@s S_endpoint_descriptor int

@<Type definition{s} ...@>=
typedef struct {
  U8 bLength;
  U8 bDescriptorType;
  U8 bEndpointAddress;
  U8 bmAttributes;
  U16 wMaxPacketSize;
  U8 bInterval; /* interval for polling EP by host to determine if data is available (ms-1) */
} S_endpoint_descriptor;

@ Interrupt IN endpoint serves when device needs to interrupt host.
Host sends IN tokens to device at a rate specified here (this endpoint is not used,
so rate is minimum possible).

@d IN (1 << 7)

@<Initialize element 6 in configuration descriptor@>= { @t\1@> @/
  7, /* size of this structure */
  0x05, /* endpoint */
  IN | 3, /* this corresponds to `3' in `ep3' on picture */
  0x03, /* transfers via interrupts\footnote\dag{Must correspond to
    |UECFG0X| of EP3.} */
  EP3_SIZE, @/
@t\2@> 0xFF /* 256 (FIXME: is it `ms'?) */
}

@ @<Initialize element 8 in configuration descriptor@>= { @t\1@> @/
  7, /* size of this structure */
  0x05, /* endpoint */
  IN | 1, /* this corresponds to `1' in `ep1' on picture */
  0x02, /* bulk transfers\footnote\dag{Must correspond to
    |UECFG0X| of EP1.} */
  EP1_SIZE, @/
@t\2@> 0x00 /* not applicable */
}

@ @d OUT (0 << 7)

@<Initialize element 9 in configuration descriptor@>= { @t\1@> @/
  7, /* size of this structure */
  0x05, /* endpoint */
  OUT | 2, /* this corresponds to `2' in `ep2' on picture */
  0x02, /* bulk transfers\footnote\dag{Must correspond to
    |UECFG0X| of EP2.} */
  EP2_SIZE, @/
@t\2@> 0x00 /* not applicable */
}

@*2 Functional descriptors.

These descriptors describe the content of the class-specific information
within an Interface descriptor. They all start with a common header
descriptor, which allows host software to easily parse the contents of
class-specific descriptors. Although the
Communication Class currently defines class specific interface descriptor
information, the Data Class does not.

\S5.2.3 in CDC spec.

@*3 Header functional descriptor.

The class-specific descriptor shall start with a header.
It identifies the release of the USB Class Definitions for
Communication Devices Specification with which this
interface and its descriptors comply.

\S5.2.3.1 in CDC spec.

@<Class-specific interface descriptor 1@>=
struct {
  U8 bFunctionLength;
  U8 bDescriptorType;
  U8 bDescriptorSubtype;
  U16 bcdCDC;
}

@ @<Initialize element 3 in configuration descriptor@>= { @t\1@> @/
  5, /* size of this structure */
  0x24, /* interface */
  0x00, /* header */
@t\2@> 0x0110 /* CDC 1.1 */
}

@*3 Abstract control management functional descriptor.

The Abstract Control Management functional descriptor
describes the commands supported by the Communication
Class interface, as defined in \S3.6.2 in CDC spec, with the
SubClass code of Abstract Control Model.

\S5.2.3.3 in CDC spec.

@<Class-specific interface descriptor 2@>=
struct {
  U8 bFunctionLength;
  U8 bDescriptorType;
  U8 bDescriptorSubtype;
  U8 bmCapabilities;
}

@ |bmCapabilities|: Only first four bits are used.
If first bit is set, then this indicates the device
supports the request combination of \.{Set\_Comm\_Feature},
\.{Clear\_Comm\_Feature}, and \.{Get\_Comm\_Feature}.
If second bit is set, then the device supports the request
combination of \.{Set\_Line\_Coding}, \.{Set\_Control\_Line\_State},
\.{Get\_Line\_Coding}, and the notification \.{Serial\_State}.
If the third bit is set, then the device supports the request
\.{Send\_Break}. If fourth bit is set, then the device
supports the notification \.{Network\_Connection}.
A bit value of zero means that the request is not supported.

@<Initialize element 4 in configuration descriptor@>= { @t\1@> @/
  4, /* size of this structure */
  0x24, /* interface */
  0x02, /* ACM */
@t\2@> 1 << 2 | 1 << 1 @/
}

@*3 Union functional descriptor.

The Union functional descriptor describes the relationship between
a group of interfaces that can be considered to form
a functional unit. One of the interfaces in
the group is designated as a master or controlling interface for
the group, and certain class-specific messages can be
sent to this interface to act upon the group as a whole. Similarly,
notifications for the entire group can be sent from this
interface but apply to the entire group of interfaces.

\S5.2.3.8 in CDC spec.

@<Class-specific interface descriptor 3@>=
struct {
  U8 bFunctionLength;
  U8 bDescriptorType;
  U8 bDescriptorSubtype;
  U8 bMasterInterface;
  U8 bSlaveInterface[SLAVE_INTERFACE_NUM];
}

@ @d SLAVE_INTERFACE_NUM 1

@<Initialize element 5 in configuration descriptor@>= { @t\1@> @/
  4 + SLAVE_INTERFACE_NUM, /* size of this structure */
  0x24, /* interface */
  0x06, /* union */
  0, /* number of CDC control interface */
  { @t\1@> @/
@t\2@> 1 /* number of CDC data interface */
@t\2@> } @/
}

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
