NOTE: disabling display via 0x0C does not seem to work - we fill buffer with zeroes instead
TODO: use only '@<Initialize display@> while (1) {}' and see if display will be blank and use
the same method instead
TODO: revert capabilities.ch and add there last change from brightness.ch and build without
brightness.ch and then try to do without ep3 and if firmware will not work, move ep3 to brightness.ch
(but without last change from brightness.ch firmware must work without ep3 - see time/TODO); in any case delete ep3 from time.w

@x
  @<Initialize display@>@;
@y
  @<Initialize display@>@;
  U8 show = 1;
@z

@x
@<Fill buffer@>@;
@y
if (!show) {
  for (U8 row = 0; row < 8; row++)
    for (U8 col = 0; col < NUM_DEVICES*8; col++)
      buffer[row][col] = 0x00;
}
else {
  @<Fill buffer@>@;
}
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
  if (speed == 1200) show = 0;
  if (speed == 2400) display_write(0x0A, 0);
  if (speed == 4800) display_write(0x0A, 15);
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
