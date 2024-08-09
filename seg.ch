@x
@<Character images@>@;
@y
const U8 segments[10] = { 126, 12, 182, 158, 204, 218, 250, 14, 254, 222 };
@z

@x
  U8 time[5];
@y
  U8 time[8];
@z

@x
DDRB |= _BV(PB6); /* latch */
@y
DDRB |= _BV(PB6); /* latch */
DDRB |= _BV(PB5), PORTB |= _BV(PB5);
@z

@x
@<Fill buffer@>@;
@<Display buffer@>@;
@y
for (int8_t i = sizeof time - 1; i >= 0; i--) {
  if (time[i] == ':') continue;
  SPDR = PORTB & _BV(PB5) ? segments[time[i] - '0'] : 0x00;
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
  if (address != 0x0C) return;
  if (data == 0x00) PORTB &= ~_BV(PB5);
  else PORTB |= _BV(PB5);
}
@z
