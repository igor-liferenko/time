@x
  @<Initialize display@>@;
@y
  @<Initialize display@>@;
  for (U8 row = 0; row < 8; row++)
    for (U8 col = 51; col < NUM_DEVICES*8; col++)
      buffer[row][col] = 0x00;
  U8 show = 1, seconds = 1;
@z
  
@x
      U8 time[8];
@y
      U8 time[9];
@z

@x
      if (time[0] == 'A') {
@y
      if (time[0] == 'A') {
        show = time[2];
        seconds = time[3];
        if (!seconds)
          for (U8 row = 0; row < 8; row++)
            for (U8 col = 32; col < NUM_DEVICES*8; col++)
              buffer[row][col] = 0x00;
@z

@x
      time[5] = '\0';
@y
      if (seconds) time[8] = '\0';
      else time[5] = '\0';
@z
  
@x
@d NUM_DEVICES 4
@y
@d NUM_DEVICES 8
@z

@x
if (blink && (time[7] % 2)) {
@y
if ((blink && (time[7] % 2)) || !show) {
@z

@x
@<Handle {\caps set control line state}@>=
wValue = UEDATX | UEDATX << 8;
UEINTX &= ~_BV(RXSTPI);
UEINTX &= ~_BV(TXINI);
if (wValue == 0) { /* blank the display when TTY is closed */
  for (U8 row = 0; row < 8; row++)
    for (U8 col = 0; col < NUM_DEVICES*8; col++)
      buffer[row][col] = 0x00;
  @<Display buffer@>@;
}
@y
@<Handle {\caps set control line state}@>=
UEINTX &= ~_BV(RXSTPI);
UEINTX &= ~_BV(TXINI);
@z
