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
  uint32_t dwDTERate = UEDATX | (uint32_t) UEDATX << 8 |
  (uint32_t) UEDATX << 16 | (uint32_t) UEDATX << 24;
  U8 a1 = UEDATX;
  U8 a2 = UEDATX;
  U8 a3 = UEDATX;
  UEINTX &= ~_BV(RXOUTI);
  UEINTX &= ~_BV(TXINI);
  UDR1 = '^'; while (!(UCSR1A & _BV(UDRE1))) { }
  hex(a1);
  hex(a2);
  hex(a3);
  UDR1 = ' '; while (!(UCSR1A & _BV(UDRE1))) { }
  switch (dwDTERate)
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
