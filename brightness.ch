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
    display_write(0x0A, 0x01), display_write(0x0C, 0x01);          
    break;              
  case 134:
    display_write(0x0A, 0x02), display_write(0x0C, 0x01);                       
    break;                            
  case 150:
    display_write(0x0A, 0x03), display_write(0x0C, 0x01);
    break;
  case 200:
    display_write(0x0A, 0x04), display_write(0x0C, 0x01);
    break;
  case 300:
    display_write(0x0A, 0x05), display_write(0x0C, 0x01);
    break;
  case 600:
    display_write(0x0A, 0x06), display_write(0x0C, 0x01);
    break;
  case 1200:
    display_write(0x0A, 0x07), display_write(0x0C, 0x01);
    break;
  case 1800:
    display_write(0x0A, 0x08), display_write(0x0C, 0x01);
    break;
  case 2400:
    display_write(0x0A, 0x09), display_write(0x0C, 0x01);
    break;
  case 4800:
    display_write(0x0A, 0x0A), display_write(0x0C, 0x01);
    break;
  case 19200:
    display_write(0x0A, 0x0B), display_write(0x0C, 0x01);
    break;
  case 38400:
    display_write(0x0A, 0x0C), display_write(0x0C, 0x01);
    break;
  case 57600:
    display_write(0x0A, 0x0D), display_write(0x0C, 0x01);
    break;
  case 49664: /* 115200 */
    display_write(0x0A, 0x0E), display_write(0x0C, 0x01);
    break;
  case 33792: /* 230400 */
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
