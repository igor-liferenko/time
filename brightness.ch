@x
      time[5] = '\0';
      @<Show |time|@>@;
@y
      if (time[0] == 'A') {
        uint8_t byte = time[1];
        if (byte >= '0' && byte <= '9') byte = byte - '0';
        else if (byte >= 'A' && byte <= 'F') byte = byte - 'A' + 10;
        display_write4(0x0A, byte), blank = 0;
      }
      else if (time[0] == 'C') blank = 1;
      else {
        if (blank) time[0] = 'X', time[1] = 'X', time[2] = 'Y', time[3] = 'X',
                   time[4] = 'X', time[5] = 'Y', time[6] = 'X', time[7] = 'X';
      time[5] = '\0';
      @<Show |time|@>@;
      }
@z

@x
    case '0': app(0); @+ break;
@y
    case '0': app(0); @+ break;
    case 'X': app(X); break;
    case 'Y': app(Y); break;
@z

@x
@<Character images@>@;
@y
uint8_t blank = 0;
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
