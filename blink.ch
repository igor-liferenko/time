@x
  @<Initialize display@>@;
@y
  @<Initialize display@>@;
  int show = 1;
@z

@x
      @<Show |time|@>@;
@y
      if (dtr_rts == 1) show = !show;
      @<Show |time|@>@;
@z

@x
@<Fill buffer@>@;
@y
if (show) {
  @<Fill buffer@>@;
}
else {
  for (uint8_t row = 0; row < 8; row++)
    for (uint8_t col = 0; col < NUM_DEVICES*8; col++)
      buffer[row][col] = 0x00;
}
@z

@x
  if (dtr_rts == 0) { /* blank the display when TTY is closed */
@y
  if (dtr_rts == 2) show = 1;
  if (dtr_rts == 0) { /* blank the display when TTY is closed */
@z
