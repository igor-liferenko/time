@x
  @<Initialize display@>@;
@y
  @<Initialize display@>@;
  for (U8 row = 0; row < 8; row++)
    for (U8 col = 51; col < NUM_DEVICES*8; col++)
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
@d NUM_DEVICES 4
@y
@d NUM_DEVICES 8
@z
