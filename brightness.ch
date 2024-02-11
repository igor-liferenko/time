NOTE: disabling display via 0x0C does not seem to work - we fill buffer with zeroes instead

@x
  @<Initialize display@>@;
@y
  @<Initialize display@>@;
  U8 show = 1;
@z

@x
      UEINTX &= ~_BV(FIFOCON);
@y
      UEINTX &= ~_BV(FIFOCON);
      if (time[0] == 'A') {
        show = time[2];
        if (show) display_write(0x0A, time[1]); /* set brightness */
        continue;
      }
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
