@x
@<Global variables@>@;
@y
@<Global variables@>@;
uint8_t glowing = 1;
uint8_t intermixed = 0; /* check if it can happen */
@z

@x
      UEINTX &= ~(1 << FIFOCON);
@y
      UEINTX &= ~(1 << FIFOCON);
      if (intermixed) continue;
      if ((time[0] >= 'A' && time[0] <= 'P')||(time[0] == 'X')) {
        if (time[7]!='-'||time[6]!='-'||time[5]!='-'||time[4]!='-'||time[3]!='-'||time[2]!='-'||
            time[1]!='-') {        
          time[0] = time[1] = time[3] = time[4] = time[6] = time[7] = '9';        
          time[2] = time[5] = ':';         
          intermixed = 1;        
          goto next;
        }
      }
      if (time[0] >= 'A' && time[0] <= 'P') {
        display_write4(0x0A, time[0] - 'A');
        glowing = 1;
        continue;
      }
      if (!glowing) continue;
      if (time[0] == 'X') glowing = 0;
      next:
@z
