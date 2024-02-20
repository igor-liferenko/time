TODO: revert capabilities.ch and add there last change from brightness.ch and build without
brightness.ch and then try to do without ep3 and if firmware will not work, move ep3 to brightness.ch
(but without last change from brightness.ch firmware must work without ep3 - see time/TODO); in any case delete ep3 from time.w

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
