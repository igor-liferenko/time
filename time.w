\datethis
\input epsf

\font\caps=cmcsc10 at 9pt

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
  @<Initialize MAX7219@>@;

  @<Setup USB Controller@>@;
  UDIEN |= _BV(EORSTE);
  sei();
  UDCON &= ~_BV(DETACH);

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
  U8 time[5];
  for (U8 i = 0; i < sizeof time; i++)
    time[i] = UEDATX;
  UEINTX &= ~_BV(FIFOCON);
  @<Show |time|@>@;
}

@ MAX7219 is a shift register.
SPI here is used as a way to push bytes to MAX7219 (data + clock).

We use latch duration of 1 us (t\lower.25ex\hbox{\the\scriptfont0 CSW} in datasheet).

Note, that segments are connected as this: clock and latch are in parallel,
DIN goes through each segment to DOUT and then to DIN of next segment in the chain.

@<Initialize MAX7219@>=
PORTB |= _BV(PB0); /* prevent the next assignment from turning on LED (on pro-micro LED is inverted) */
DDRB |= _BV(PB0); /* disable SPI slave mode (\.{SS} port) */
DDRB |= _BV(PB1); /* clock */
DDRB |= _BV(PB2); /* data */
DDRB |= _BV(PB6); /* latch */
SPCR |= _BV(MSTR) | _BV(SPR1) | _BV(SPE), _delay_ms(500);
display_write(0x0F, 0x00);
display_write(0x0B, 0x07);
display_write(0x0A, 0x0F);
display_write(0x09, 0x00);
for (U8 a = 0x01; a <= 0x08; a++)
  display_write(a, 0x00);
display_write(0x0C, 0x01);

@ @<Global variables@>=
U8 buffer[8][NUM_DEVICES*8];

@ First we assemble the images of received characters in buffer, then we display parts
of buffer corresponding to each device.

@d NUM_DEVICES 4

@<Show |time|@>=
@<Fill buffer@>@;
@<Display buffer@>@;

@ @d app(X) /* append row of specified character image to buffer */
for (U8 c = 0; c < sizeof
                         @t}\begingroup\def\vb#1{\\{#1}\endgroup@>@=chr_@>##X / 8; c++)
  buffer[row][col++] = pgm_read_byte(&@t}\begingroup\def\vb#1{\\{#1}\endgroup@>@=chr_@>##X[row][c])

@<Fill buffer@>=
for (U8 row = 0; row < 8; row++) {
  U8 col = 0;
  buffer[row][col++] = 0x00;
  for (U8 i = 0; i < sizeof time; i++) {
    switch (time[i])
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
    for (U8 c = 0; c < 8; c++)
      if (buffer[row][n * 8 + c])
        data |= 1 << 7 - c;
    display_push(row + 1, data);
  }
  PORTB |= _BV(PB6), _delay_us(1), PORTB &= ~_BV(PB6);
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
void display_write(U8 address, U8 data)
{
  for (U8 n = 0; n < NUM_DEVICES; n++)
    display_push(address, data);
  PORTB |= _BV(PB6), _delay_us(1), PORTB &= ~_BV(PB6);
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

@ \S22.6 in datasheet.

@<Create ISR for USB\_RESET@>=
@.ISR@>@t}\begingroup\def\vb#1{\.{#1}\endgroup@>@=ISR@>
  (@.USB\_GEN\_vect@>@t}\begingroup\def\vb#1{\.{#1}\endgroup@>@=USB_GEN_vect@>)
{
  UENUM = 0;
  UECONX |= _BV(EPEN);
  UECFG1X |= _BV(EPSIZE0) | _BV(EPSIZE1) | _BV(ALLOC); /* the same as |EP0_SIZE| */
  @#
  UDINT &= ~_BV(EORSTI);
}

@ \S21.13 in datasheet.

@<Setup USB Controller@>=
UHWCON |= _BV(UVREGE);
PLLCSR |= _BV(PINDIV);
PLLCSR |= _BV(PLLE);
while (!(PLLCSR & _BV(PLOCK))) { }
USBCON |= _BV(USBE);
USBCON &= ~_BV(FRZCLK);
USBCON |= _BV(OTGPADE);

@* USB connection.

@<Global variables@>=
U16 wValue;
U16 wIndex;
U16 wLength;

@ \S5.5.3 in USB spec.

@<Functions@>=
void send_descriptor(const void *buf, U16 size)
{
  for (U8 c = size / EP0_SIZE; c > 0; c--) {
    for (U8 c = EP0_SIZE; c > 0; c--) UEDATX = pgm_read_byte(buf++);
    UEINTX &= ~_BV(TXINI);
    if (c != 1 || size % EP0_SIZE || size != wLength) while (!(UEINTX & _BV(TXINI))) { }
  }
  if (size % EP0_SIZE) {
    for (U8 c = size % EP0_SIZE; c > 0; c--) UEDATX = pgm_read_byte(buf++);
    UEINTX &= ~_BV(TXINI);
  }
  else if (size != wLength) UEINTX &= ~_BV(TXINI);
}

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
  case 0x0200 | CONF_NUM - 1: @/
    @<Handle {\caps get descriptor configuration}@>@;
    break;
  case 0x0600: /* full-speed or high-speed ? */
    UECONX |= _BV(STALLRQ); /* full-speed */
    UEINTX &= ~_BV(RXSTPI);
  }
  break;
case 0x0900: @/
  @<Handle {\caps set configuration}@>@;
  break;
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
send_descriptor(&dev_desc, wLength > sizeof dev_desc ? sizeof dev_desc : wLength);
while (!(UEINTX & _BV(RXOUTI))) { }
UEINTX &= ~_BV(RXOUTI);

@ @<Handle {\caps get descriptor configuration}@>=
(void) UEDATX; @+ (void) UEDATX;
wLength = UEDATX | UEDATX << 8;
UEINTX &= ~_BV(RXSTPI);
send_descriptor(&conf_desc, wLength > sizeof conf_desc ? sizeof conf_desc : wLength);
while (!(UEINTX & _BV(RXOUTI))) { }
UEINTX &= ~_BV(RXOUTI);

@ @<Handle {\caps set configuration}@>=
wValue = UEDATX | UEDATX << 8;
UEINTX &= ~_BV(RXSTPI);
UEINTX &= ~_BV(TXINI);
if (wValue == CONF_NUM) {
  @<Configure EP2@>@;
}

@* USB descriptors.

@*1 Device descriptor.

\S9.6.1 in USB spec; \S5.1.1 in CDC spec.

@d EP0_SIZE 64 /* the same as in configuration of EP0 */

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
  1, /* DEVICE */
  0x0200, /* 2.0 */
  0x02, /* Communication Device class */
  0x00, /* constant */
  0x00, /* constant */
  EP0_SIZE, @/
  0x03EB, @/
  0x2018, @/
  0x0100, /* 1.0 */
  0, /* no string */
  0, /* no string */
  0, /* no string */
@t\2@> 1 /* see |CONF_NUM| */
};

@*1 Configuration descriptor.

@<Global variables@>=
struct {
  @<Configuration descriptor@>@;
  @<Interface descriptor@>@;
  @<Header functional descriptor@>@;
  @<Abstract Control Management functional descriptor@>@;
  @<Union functional descriptor@>@;
  @<Interface descriptor@>@;
  @<Endpoint descriptor@>@;
} const conf_desc
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/
  @<Initialize Configuration descriptor@>, @/
  @<Initialize Communication Class Interface descriptor@>, @/
  @<Initialize Header functional descriptor@>, @/
  @<Initialize Abstract Control Management functional descriptor@>, @/
  @<Initialize Union functional descriptor@>, @/
  @<Initialize Data Class Interface descriptor@>, @/
@t\2@> @<Initialize EP2 descriptor@> @/
};

@*2 Configuration descriptor.

\S9.6.3 in USB spec.

@d CONF_NUM 1 /* see last parameter in |dev_desc| */

@<Initialize Configuration descriptor@>=
SIZEOF_THIS, @/
2, /* CONFIGURATION */
SIZEOF_CONF_DESC, @/
1 + 1, /* Communication (master) interface + Data (slave) interface(s) */
CONF_NUM, @/
0, @/
1 << 7, @/
250 /* 500 mA */

@*2 Communication Class Interface descriptor.

\S9.6.5 in USB spec; \S5.1.3 in CDC spec.

@d CTRL_IFACE_NUM 0

@<Initialize Communication Class Interface descriptor@>=
SIZEOF_THIS, @/
4, /* INTERFACE */
CTRL_IFACE_NUM, @/
0, /* no alternate settings */
0, /* no endpoints */
0x02, /* Communication Interface class */
0x02, /* Abstract Control Model */
0x00, /* no protocol */
0 /* no string */

@*3 Header functional descriptor.

\S5.2.3.1 in CDC spec.

@<Initialize Header functional descriptor@>=
SIZEOF_THIS, @/
0x24, @/
0x00, @/
0x0110 /* 1.1 */

@*3 Abstract Control Management functional descriptor.

\S5.2.3.3 in CDC spec.

@<Initialize Abstract Control Management functional descriptor@>=
SIZEOF_THIS, @/
0x24, @/
0x02, @/
0

@*3 Union functional descriptor.

\S5.2.3.8 in CDC spec.

@<Initialize Union functional descriptor@>=
SIZEOF_THIS, @/
0x24, @/
0x06, @/
CTRL_IFACE_NUM, @/
DATA_IFACE0_NUM

@*3 Data Class Interface descriptor.

\S9.6.5 in USB spec; \S5.1.3 in CDC spec.

@d DATA_IFACE0_NUM 1

@<Initialize Data Class Interface descriptor@>=
SIZEOF_THIS, @/
4, /* INTERFACE */
DATA_IFACE0_NUM, @/
0, /* no alternate settings */
1, /* one endpoint (OUT) */
0x0A, /* Data Interface class */
0x00, /* constant */
0x00, /* no protocol */
0 /* no string */

@*4 EP2 descriptor.

\S9.6.6 in USB spec.

@<Initialize EP2 descriptor@>=
SIZEOF_THIS, @/
5, /* ENDPOINT */
2 | 0, @/
0x02, @/
8, @/
0

@ \S22.6 in datasheet.

@<Configure EP2@>=
UENUM = 2;
UECONX |= _BV(EPEN);
UECFG0X |= _BV(EPTYPE1);
UECFG1X |= _BV(ALLOC);

@*2 \bf Configuration descriptor.

@ Configuration descriptor.

\S9.6.3 in USB spec.

@<Configuration descriptor@>=
U8 bLength;
U8 bDescriptorType;
U16 wTotalLength;
U8 bNumInterfaces;
U8 bConfigurationValue;
U8 iConfiguration;
U8 bmAttibutes;
U8 bMaxPower;

@ Interface descriptor.

\S9.6.5 in USB spec.

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

@<Header functional descriptor@>=
U8 bFunctionLength;
U8 bDescriptorType;
U8 bDescriptorSubtype;
U16 bcdCDC;

@ Abstract Control Management functional descriptor.

\S5.2.3.3 in CDC spec.

@<Abstract Control Management functional descriptor@>=
U8 bFunctionLength;
U8 bDescriptorType;
U8 bDescriptorSubtype;
U8 bmCapabilities;

@ Union functional descriptor.

\S5.2.3.8 in CDC spec.

@<Union functional descriptor@>=
U8 bFunctionLength;
U8 bDescriptorType;
U8 bDescriptorSubtype;
U8 bMasterInterface;
U8 bSlaveInterface0;

@ Endpoint descriptor.

\S9.6.6 in USB spec.

@<Endpoint descriptor@>=
U8 bLength;
U8 bDescriptorType;
U8 bEndpointAddress;
U8 bmAttributes;
U16 wMaxPacketSize;
U8 bInterval;

@* Headers.

@<Header files@>=
#include <avr/boot.h>
#include <avr/interrupt.h>
#include <avr/io.h>
#include <avr/pgmspace.h>
#include <util/delay.h>
