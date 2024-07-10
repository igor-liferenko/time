@x
@<Character images@>@;
@y
const U8 chr[10] PROGMEM = { 126, 48, 109, 121, 51, 91, 95, 112, 127, 123 };
U8 glowing = 1;
@z

@x
  U8 time[6] = {};
  for (U8 c = 0; c < 5; c++)
@y
  U8 time[9] = {};
  for (U8 c = 0; c < 8; c++)
@z

@x
DDRB |= _BV(PB6); /* latch */
@y
DDRB |= _BV(PB6), PORTB |= _BV(PB6); /* latch */
@z

@x
display_write(0x0F, 0x00);
display_write(0x0B, 0x07);
display_write(0x0A, 0x0F);
display_write(0x09, 0x00);
for (U8 c = 1; c <= 8; c++)
  display_write(c, 0x00);
display_write(0x0C, 0x01);
@y
@z

@x
U8 buffer[8][NUM_DEVICES*8];
@y
U8 buffer[NUM_DEVICES];
@z

@x
@d NUM_DEVICES 4
@y
@d NUM_DEVICES 6
@z

@x
@<Fill buffer@>@;
@y
U8 n = 0;
for (U8 *c = time; *c != '\0'; c++)
  if (*c != ':')
    buffer[n++] = chr[*c-'0'];
@z

@x
@<Display buffer@>@;
@y
PORTB &= ~_BV(PB6); /* latch */
for (U8 n = 0; n < NUM_DEVICES; n++)
  if (glowing) {
    display_push(0, buffer[n]);
    // TODO: add here turning on `:'
  }
  else {
    display_push(0, 0x00);
    // TODO: add here turning off `:'
  }
PORTB |= _BV(PB6); /* latch */
@z

@x
void display_push(U8 address, U8 data)
{
  SPDR = address;
  while (!(SPSR & _BV(SPIF))) { }
@y
void display_push(U8 address, U8 data)
{
@z

@x
case 0x0900: @/
  @<Handle {\caps set configuration}@>@;
  break;
@y
case 0x0900: @/
  @<Handle {\caps set configuration}@>@;
  break;
case 0x2021: /* set line coding (Table 50 in CDC spec) */
  UEINTX &= ~_BV(RXSTPI);
  while (!(UEINTX & _BV(RXOUTI))) { }
  uint32_t dwDTERate = UEDATX | (uint32_t) UEDATX << 8 |
    (uint32_t) UEDATX << 16 | (uint32_t) UEDATX << 24;
  UEINTX &= ~_BV(RXOUTI);
  UEINTX &= ~_BV(TXINI);
  glowing = dwDTERate == 50 ? 0 : 1;
  break;
@z
