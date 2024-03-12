@x
  @<Initialize MAX7219@>@;
@y
  @<Initialize MAX7219@>@;
  for (U8 row = 0; row < 8; row++)
    for (U8 col = 51; col < NUM_DEVICES*8; col++)
      buffer[row][col] = 0x00;
@z
  
@x
  U8 time[6] = {};
  for (U8 c = 0; c < 5; c++)
@y
  U8 time[9] = {};
  for (U8 c = 0; c < 8; c++)
@z

@x
@d NUM_DEVICES 4
@y
@d NUM_DEVICES 8
@z
