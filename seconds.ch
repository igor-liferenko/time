@x
  @<Initialize display@>@;
@y
  @<Initialize display@>@;
  for (U8 row = 0; row < 8; row++)
    for (U8 col = 19; col < NUM_DEVICES*8; col++)
      buffer[row][col] = 0x00;
@z

@x
      U8 time[8];
@y
      U8 time[9];
@z

@x
      time[5] = '\0';
@y
      time[8] = '\0';
@z

@x
  buffer[row][col++] = 0x00;
  for (U8 *c = time; *c != '\0'; c++) {
@y
  for (U8 *c = time+5; *c != '\0'; c++) {
@z
