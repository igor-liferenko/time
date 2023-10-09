@x
      UEINTX &= ~(1 << FIFOCON);
@y
      UEINTX &= ~(1 << FIFOCON);
      if (time[0] == 'A') {
        display_write4(0x0A, time[1]);
        continue;
      }
@z
