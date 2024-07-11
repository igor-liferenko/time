@x
@<Character images@>@;
@y
const U8 chr[10] = { 126+1,  12+1, 182+1, 158+1, 204+1,
                     218+1, 250+1,  14+1, 254+1, 222+1 };
@z

@x
  U8 time[6] = @[{}@];
  for (U8 c = 0; c < 5; c++)
@y
  U8 time[9] = @[{}@];
  for (U8 c = 0; c < 8; c++)
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
for (U8 i = 0; i < NUM_DEVICES; i++) {
  SPDR = glowing ? buffer[i] : 0;
  while (!(SPSR & _BV(SPIF))) { }
}
PORTB |= _BV(PB6), _delay_ms(1), PORTB &= ~_BV(PB6); /* latch */
@z

@x
void display_write(U8 address, U8 data)
{
  for (U8 c = 0; c < NUM_DEVICES; c++)
    display_push(address, data);
  PORTB |= _BV(PB6), _delay_us(1), PORTB &= ~_BV(PB6); /* latch */
}
@y
U8 glowing;
void display_write(U8 address, U8 data)
{
  if (address == 0x0C) glowing = data;
}
@z
