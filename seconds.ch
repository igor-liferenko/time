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
  buffer[row][col++] = 0x00;
  for (char *c = time; *c != '\0'; c++) {
@y
  for (char *c = time+5; *c != '\0'; c++) {
@z

@x
    buffer[row][col++] = 0x00;
  }
@y
    buffer[row][col++] = 0x00;
  }
  while (col < NUM_DEVICES*8) buffer[row][col++] = 0x00;
@z
