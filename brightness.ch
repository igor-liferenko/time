NOTE: disabling/enabling display via `C' command does not work properly, so use empty characters X and Y

@x
      UEINTX &= ~(1 << FIFOCON);
@y
      UEINTX &= ~(1 << FIFOCON);
      if (time[0] == 'A') {
        uint8_t byte = time[1];
        if (byte >= '0' && byte <= '9') byte = byte - '0';
        else if (byte >= 'A' && byte <= 'F') byte = byte - 'A' + 10;
        display_write4(0x0A, byte);
        glowing = 1;
        continue;
      }
      if (!glowing) continue;
      if (time[0] == 'C') {
        strncpy(time, "XXYXXYXX", 8);
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

@x
@<Header files@>=
@y
@<Header files@>=
#include <string.h>
@z
