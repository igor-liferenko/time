NOTE: pins 1-7 of SN74HC595 must be connected to inputs of ULN2003APG,
      and corresponding outputs of ULN2003APG - to segments 1-7 of a
      digit (counting clockwise from top segment)

@x
@<Character images@>@;
@y
const U8 segments[10] = { 126+1,  12+1, 182+1, 158+1, 204+1,
                          218+1, 250+1,  14+1, 254+1, 222+1 };
U8 glowing;
@z

@x
  U8 time[5];
@y
  U8 time[8];
@z

@x
@<Fill buffer@>@;
@<Display buffer@>@;
@y
for (int8_t i = sizeof time - 1; i >= 0; i--) {
  if (time[i] == ':') continue;
  SPDR = glowing ? segments[time[i] - '0'] : 0x00;
  while (!(SPSR & _BV(SPIF))) { }
}
PORTB &= ~_BV(PB6), PORTB |= _BV(PB6);
@z

@x
void display_write(U8 address, U8 data)
{
  for (U8 n = 0; n < NUM_DEVICES; n++)
    display_push(address, data);
  PORTB &= ~_BV(PB6), PORTB |= _BV(PB6);
}
@y
void display_write(U8 address, U8 data)
{
  if (address == 0x0C) glowing = data;
}
@z
