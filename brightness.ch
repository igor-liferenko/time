@x
  UENUM = 2;
  UECONX &= ~_BV(EPEN);
  UECFG1X &= ~_BV(ALLOC);
@y
  UENUM = 2;
  UECONX &= ~_BV(EPEN);
  UECFG1X &= ~_BV(ALLOC);
  @#
  UENUM = 3;
  UECONX &= ~_BV(EPEN);
  UECFG1X &= ~_BV(ALLOC);
@z

@x
case 0x0900: @/
  @<Handle {\caps set configuration}@>@;
  break;
@y
case 0x0900: @/
  @<Handle {\caps set configuration}@>@;
  break;
case 0x2021: /* set line coding (Table 50 in CDC spec) */
  UEINTX &= ~_BV(RXSTPI);
  while (!(UEINTX & _BV(RXOUTI))) { }
  U16 speed = UEDATX | UEDATX << 8;
  UEINTX &= ~_BV(RXOUTI);
  UEINTX &= ~_BV(TXINI);
  if (speed == 1200) {
    display_write(0x01, 0x00);
    display_write(0x02, 0x00);
    display_write(0x03, 0x00);
    display_write(0x04, 0x00);
    display_write(0x05, 0x00);
    display_write(0x06, 0x00);
    display_write(0x07, 0x00);
    display_write(0x08, 0x00);
    display_write(0x0C, 0x00);
  }
  if (speed == 2400) display_write(0x0A, 0), display_write(0x0C, 0x01);
  if (speed == 4800) display_write(0x0A, 15), display_write(0x0C, 0x01);
  break;
case 0x2221: /* set control line state */
  UEINTX &= ~_BV(RXSTPI);
  UEINTX &= ~_BV(TXINI);
  break;
@z

@x
  @<Configure EP2@>@;
@y
  @<Configure EP2@>@;
  @<Configure EP3@>@;
@z

@x
  @<Union functional descriptor@>@;
@y
  @<Union functional descriptor@>@;
  @<Endpoint descriptor@>@;
@z

@x
  @<Initialize Data Class Interface descriptor@>, @/
@y
  @<Initialize EP3 descriptor@>, @/
  @<Initialize Data Class Interface descriptor@>, @/
@z

@x
0, /* no endpoints */
@y
1, /* one endpoint (notification) */
@z

@x
@<Initialize Abstract Control Management functional descriptor@>=
SIZEOF_THIS, @/
0x24, @/
0x02, @/
0
@y
@<Initialize Abstract Control Management functional descriptor@>=
SIZEOF_THIS, @/
0x24, @/
0x02, @/
1 << 1
@z

@x
@*3 Data Class Interface descriptor.
@y
@*3 EP3 descriptor.

\S9.6.6 in USB spec.

@<Initialize EP3 descriptor@>=
SIZEOF_THIS, @/ 
5, /* ENDPOINT */
3 | 1 << 7, @/
0x03, @/
8, @/
0xFF

@ @<Configure EP3@>=
UENUM = 3;
UECONX |= _BV(EPEN);
UECFG0X = _BV(EPTYPE0) | _BV(EPTYPE1) | _BV(EPDIR);
UECFG1X = 0;
UECFG1X |= _BV(ALLOC);

@*3 Data Class Interface descriptor.
@z
