NOTE: see doc-part of section @<Set brightness...@>
FIXME: does native wire work without SPR1? I.e., is SPR1 for long wire also?

@x
  PORTB |= 1 << PB6; @+ _delay_us(1); @+ PORTB &= ~(1 << PB6);
@y
  _delay_us(1);
  PORTB |= 1 << PB6; @+ _delay_us(1); @+ PORTB &= ~(1 << PB6);
@z

@x
  PORTB |= 1 << PB6; @+ _delay_us(1); @+ PORTB &= ~(1 << PB6);
@y
  _delay_us(1);
  PORTB |= 1 << PB6; @+ _delay_us(1); @+ PORTB &= ~(1 << PB6);
@z
