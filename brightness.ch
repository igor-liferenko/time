NOTE: disabling/enabling display via `C' command does not work properly, so use empty characters X and Y

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
        time[0] = time[1] = time[3] = time[4] = time[6] = time[7] = 'X';
        time[2] = time[5] = 'Y';
        glowing = 0;
      }
@z

@x
    case '9': app(9); @+ break;
@y
    case '9': app(9); @+ break;
    case 'X': app(X); break;
    case 'Y': app(Y); break;
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
