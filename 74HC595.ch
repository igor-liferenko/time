NOTE: pins 1-7 of 74HC595 must be connected to inputs of ULN2003APG,
      and corresponding outputs of ULN2003APG - to segments 1-7 of a
      digit (counting clockwise from top segment)

@x
@<Character images@>@;
@y
const U8 chr[10] = { 126+1,  12+1, 182+1, 158+1, 204+1,
                     218+1, 250+1,  14+1, 254+1, 222+1 };
@z

@x
  U8 time[5];
@y
  U8 time[8];
@z

@x
U8 buffer[8][NUM_DEVICES*8];
@y
U8 buffer[NUM_DEVICES];
U8 glowing;
@z

@x
@d NUM_DEVICES 4
@y
@d NUM_DEVICES 6
@z

@x
@<Fill buffer@>@;
@y
for (U8 c = 0, n = sizeof buffer; c < sizeof time; c++)
  if (time[c] != ':')
    buffer[--n] = chr[time[c]-'0'];
@z

@x
@<Display buffer@>@;
@y
PORTB &= ~_BV(PB6); /* latch */
for (U8 n = 0; n < NUM_DEVICES; n++) {
  SPDR = glowing ? buffer[n] : 0;
  while (!(SPSR & _BV(SPIF))) { }
}
PORTB |= _BV(PB6); /* latch */
@z

@x
void display_write(U8 address, U8 data)
{
  for (U8 c = 0; c < NUM_DEVICES; c++)
    display_push(address, data);
  PORTB |= _BV(PB6), _delay_us(1), PORTB &= ~_BV(PB6); /* latch */
}
@y
void display_write(U8 address, U8 data)
{
  if (address == 0x0C) glowing = data;
}
@z
