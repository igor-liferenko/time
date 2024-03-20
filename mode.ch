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
  UEINTX &= ~_BV(RXOUTI);
  UEINTX &= ~_BV(TXINI);
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
@z
