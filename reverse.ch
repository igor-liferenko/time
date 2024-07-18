@x
  for (U8 n = 0; n < NUM_DEVICES; n++) {
@y
  for (int8_t n = NUM_DEVICES-1; n >= 0; n--) {
@z

@x
        data |= 1 << 7 - c;
    display_push(row + 1, data);
@y
        data |= 1 << c;
    display_push(7 - row + 1, data);
@z
