@x
  @<Initialize display@>@;
@y
  @<Initialize display@>@;
  uint8_t buffer[8][NUM_DEVICES*8];
  for (uint8_t row = 0; row < 8; row++)
    for (uint8_t col = 0; col < NUM_DEVICES*8; col++)
      buffer[row][col] = 0x00;
@z

@x
      char time[8];
@y
      char time[9];
@z

@x
      time[5] = '\0';
@y
      time[8] = '\0';
@z

@x
uint8_t buffer[8][NUM_DEVICES*8];
@y
@z

@x
  buffer[row][col++] = 0x00;
  for (char *c = time; *c != '\0'; c++) {
@y
  for (char *c = time+5; *c != '\0'; c++) {
@z
