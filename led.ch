@x
  @<Initialize display@>@;
@y
  @<Initialize display@>@;
  PORTD |= _BV(PD5); /* on pro-micro led is inverted */
  DDRD |= _BV(PD5); /* set output mode */
@z

@x
      UEINTX &= ~_BV(FIFOCON);
@y
      UEINTX &= ~_BV(FIFOCON);
      if (time[0] == 'A')
        if (time[7]) PORTD &= ~_BV(PD5); else PORTD |= _BV(PD5);
@z
