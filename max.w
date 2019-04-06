@ $$\hbox to7cm{\vbox to4.21cm{\vfil\special{psfile=max.eps
  clip llx=0 lly=0 urx=490 ury=295 rwi=1984}}\hfil}$$

$$\hbox to8.35cm{\vbox to2.2225cm{\vfil\special{psfile=MAX.1
  clip llx=-38 lly=37 urx=57 ury=100 rwi=950}}\kern5cm
  \vbox to1.48166666666667cm{\vfil\special{psfile=MAX.2
  clip llx=-142 lly=-21 urx=-28 ury=21 rwi=1140}}\hfil}$$

@c
#include <avr/io.h>

void display_write(unsigned int dc) /* FIXME: will it work without `|unsigned|'? */
{
  for (int i = 16; i > 0; i--) { // shift 16 bits out, msb first
    if (dc & 1 << 15) @+ PORTB |= 1 << PB2;
    else @+ PORTB &= ~(1 << PB2);
    PORTB &= ~(1 << PB1); @+ PORTB |= 1 << PB1;
    dc <<= 1;
  }
  PORTB |= 1 << PB3; @+ PORTB &= ~(1 << PB3);
}

void main(void)
{
  DDRB |= 1 << PB1 | 1 << PB2 | 1 << PB3;
  @<Initialize@>@;
  @<Clear@>@;
}

@ @<Initialize@>=
#if 0
display_write(0x0F << 8 | 0x00); /* to be safe --- may be occasionally enabled
  while programming, because the same pins are used */
#endif
display_write(0x0B << 8 | 0x07); /* number of displayed characters */
display_write(0x09 << 8 | 0xFF); /* decode mode */
display_write(0x0A << 8 | 0x05); /* brightness */
display_write(0x0C << 8 | 0x01); /* enable */

@ @<Clear@>=
display_write(0x01 << 8 | 4);
display_write(0x02 << 8 | 0);
display_write(0x03 << 8 | 0x0F);
display_write(0x04 << 8 | 2);
display_write(0x05 << 8 | 3);
display_write(0x06 << 8 | 0x0F);
display_write(0x07 << 8 | 5);
display_write(0x08 << 8 | 3);
