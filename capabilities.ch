According to Table 28 in CDC spec, these two requests must not happen
because we set bmCapabilities to zero in
@<Initialize Abstract Control Management functional descriptor@>.
But they do happen. So we use ch-file to keep handling them
out of main program - as if they did not happen.

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
  UEINTX &= ~_BV(RXOUTI);
  UEINTX &= ~_BV(TXINI);
  break;
case 0x2221: /* set control line state */  
  UEINTX &= ~_BV(RXSTPI);
  UEINTX &= ~_BV(TXINI);
  break;
@z
