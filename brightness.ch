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
    for (U8 c = 1; c <= 8; c++)
      display_write(c, 0x00);
    display_write(0x0C, 0x00);
  }
  if (speed == 2400) display_write(0x0A, 0x00), display_write(0x0C, 0x01);
  if (speed == 4800) display_write(0x0A, 0x0F), display_write(0x0C, 0x01);
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
1 << 1 /* device supports `set line coding' and `set control line state' */
@z
