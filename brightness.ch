NOTE: disabling/enabling display via `C' command does not work properly, so use empty characters X
      and Y

@x
      UEINTX &= ~(1 << FIFOCON);
@y
      UEINTX &= ~(1 << FIFOCON);
      if (time[0] == 'A')
      if (time[1] >= 0 && time[1] <= 15)
      if (time[2] == '-')
      if (time[3] == '-')
      if (time[4] == '-')
      if (time[5] == '-')  
      if (time[6] == '-')  
      if (time[7] == '-') {
        display_write4(0x0A, time[1]);
        glowing = 1;
        continue;
      }
      if (!glowing) continue;
      if (time[0] == 'C')
      if (time[1] == '-')    
      if (time[2] == '-')  
      if (time[3] == '-')  
      if (time[4] == '-')  
      if (time[5] == '-')   
      if (time[6] == '-')   
      if (time[7] == '-') {
        time[0] = time[1] = time[3] = time[4] = time[6] = time[7] = '/';
        time[2] = time[5] = '.';
        glowing = 0;
      }
      if (time[0] >= 46 && time[0] <= 58)
      if (time[1] >= 46 && time[1] <= 58)
      if (time[2] >= 46 && time[2] <= 58)    
      if (time[3] >= 46 && time[3] <= 58)
      if (time[4] >= 46 && time[4] <= 58)
      if (time[5] >= 46 && time[5] <= 58)
      if (time[6] >= 46 && time[6] <= 58)
      if (time[7] >= 46 && time[7] <= 58) goto next;
      continue; /* if data is intermixed due to simultaneous write to the TTY of `time-write' and
                   `printf **------ >/dev/ttyACMx' commands, just ignore it */
      next:
@z

@x
    case '9': app(9); @+ break;
@y
    case '9': app(9); @+ break;
    case '/': app(X); break;
    case '.': app(Y); break;
@z

@x
@<Character images@>@;
@y
uint8_t glowing = 1;
const uint8_t chr_X[8][5] PROGMEM = {
  { 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0 }
};
const uint8_t chr_Y[8][6] PROGMEM = {
  { 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0 }
};
@<Character images@>@;
@z
