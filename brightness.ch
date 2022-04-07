@x
  while (1) {
@y
  uint8_t glowing = 1;
  while (1) {
@z

@x
      UEINTX &= ~(1 << FIFOCON);
@y
      UEINTX &= ~(1 << FIFOCON);
      if (time[0] >= 'A' && time[0] <= 'P') {
        display_write4(0x0A, time[0] - 'A');
        glowing = 1;
        continue;
      }
      if (!glowing) continue;
      if (time[0] == 'X') {
        time[7] = time[6] = time[5] = time[4] = time[3] = time[2] = time[1] = time[0];
        glowing = 0;
      }
@z
