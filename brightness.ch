@x
@<Global variables@>@;
@y
@<Global variables@>@;
uint8_t glowing = 1;
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
      if (time[0] == 'X') glowing = 0;
@z
