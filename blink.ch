@x
  @<Initialize display@>@;
@y
  @<Initialize display@>@;
  int blink = 0;
@z

@x
        display_write4(0x0A, time[1]); /* set brightness */
@y
        display_write4(0x0A, time[1]); /* set brightness */
        blink = time[7];
@z

@x
@<Fill buffer@>@;
@y
if (blink && (time[7] % 2)) {
  for (U8 row = 0; row < 8; row++)
    for (U8 col = 0; col < NUM_DEVICES*8; col++)
      buffer[row][col] = 0x00;
}
else {
  @<Fill buffer@>@;
}
@z
