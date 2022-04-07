If intermix is possible, then the current code (without validation)
can happily work - just wrong brightness value can be set and some
digits can be missed. TODO: check if the same applies to commit b5b63b which is the current
firmware

So, let it work for some time and see if one of these faults happens. If it never happens, then
intermix is impossible (I suspect that minimal USB packet size of 8 bits may determine this,
and each packet in this program is exactly 8 bits) and current code may be left as-is. If it
happens, then add data validation here.

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
      if (time[0] == 'A') {
        display_write4(0x0A, time[1]);
        glowing = 1;
        continue;
      }
      if (!glowing) continue;
      if (time[0] == 'C') {
        time[0] = time[1] = time[2] = time[3] = time[4] = time[5] = time[6] = time[7] = 'X';
        glowing = 0;
      }
@z
