@x
  for (U8 n = 0; n < NUM_DEVICES; n++) {
@y
  for (U8 n = NUM_DEVICES; n-- > 0; ) {
@z

@x
        data |= 1 << 7-i;
    display_push(row+1, data);
@y
        data |= 1 << i;
    display_push(7-row+1, data);
@z
