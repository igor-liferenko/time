@x
      time[5] = '\0';
@y
@z

On left panel there is one space in the end, so on right panel we must start with character.
@x
  buffer[row][col--] = 0x00;
  for (char *c = time; *c != '\0'; c++) {
@y
  for (char *c = time+5; *c != '\0'; c++) { /* output only separator and seconds */
@z

@x
    buffer[row][col--] = 0x00;
  }
@y
    buffer[row][col--] = 0x00;
  }
  while (col >= 0) buffer[row][col--] = 0x00; /* the rest is empty */
@z
