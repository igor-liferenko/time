There are two things to keep in mind when we use this method:

  1) data is sent only if one of the 4 parameters is changed
     from its current value
  2) set_line_coding 9600-8N1 is automatically sent by host
     after set_configuration request

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
  uint32_t speed = UEDATX | (uint32_t) UEDATX << 8 |
  (uint32_t) UEDATX << 16 | (uint32_t) UEDATX << 24;
  UEINTX &= ~_BV(RXOUTI);
  UEINTX &= ~_BV(TXINI);
  switch (speed)
  {
  case 50:
    for (U8 c = 1; c <= 8; c++)
      display_write(c, 0x00);
    display_write(0x0C, 0x00);
    break;
  case 75:
    display_write(0x0A, 0x00), display_write(0x0C, 0x01);
    break;
  case 110:
    display_write(0x0A, 0x0F), display_write(0x0C, 0x01);
  }
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
