\let\lheader\rheader
%\datethis
\secpagedepth=2 % begin new page only on *
\font\caps=cmcsc10 at 9pt

@* Program.

$$\hbox to7cm{\vbox to5.55cm{\vfil\special{psfile=max-pic.eps
  clip llx=0 lly=0 urx=431 ury=342 rwi=1984}}\hfil}$$

FIXME: see how to make images side-by-side in tex/TIPS
$$\hbox to8.35cm{\vbox to2.2225cm{\vfil\special{psfile=MAX.1
  clip llx=-38 lly=37 urx=57 ury=100 rwi=950}}\kern5cm
  \vbox to1.48166666666667cm{\vfil\special{psfile=MAX.2
  clip llx=-142 lly=-21 urx=-28 ury=21 rwi=1140}}\hfil}$$

@c
@<Header files@>@;
@<Type definitions@>@;
@<Global variables@>@;
@<Create ISR for connecting to USB host@>@;

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
  @<Connect to USB host (must be called first; |sei| is called here)@>@;

  DDRB |= 1 << PB1 | 1 << PB2 | 1 << PB3;
  display_write(0x0B << 8 | 0x07); /* all characters are used */
  display_write(0x09 << 8 | 0xFF); /* decode mode */
  display_write(0x0A << 8 | 0xFF); /* brightness */
  display_write(0x0C << 8 | 0x01); /* enable */

  while (1) {
    @<If there is a request on |EP0|, handle it@>@;
    UENUM = EP2;
    if (UEINTX & 1 << RXOUTI) {
      UEINTX &= ~(1 << RXOUTI);
      int rx_counter = UEBCLX;
      char s[9];
      int i = 0;
      while (rx_counter--)
        s[i++] = UEDATX;
      s[8] = '\0';
      UEINTX &= ~(1 << FIFOCON);
      if (strcmp(s, "06:00:00") == 0)
        display_write(0x0A << 8 | 0xFF);
      if (strcmp(s, "21:00:00") == 0)
        display_write(0x0A << 8 | 0x01);
      for (i = 0; i < 8; i++)
        display_write((8-i)<<8|(s[i]==':'?0x0F:s[i]-48));
    }
  }
}

@ No other requests except {\caps set control line state} come
after connection is established. These are from \\{open} and implicit \\{close}
in \.{time-write}. Just discard the data.

@<If there is a request on |EP0|, handle it@>=
UENUM = EP0;
if (UEINTX & 1 << RXSTPI) {
  UEINTX &= ~(1 << RXSTPI);
  UEINTX &= ~(1 << TXINI); /* STATUS stage */
}

@i ../usb/OUT-endpoint-management.w
@i ../usb/USB.w

@ Program headers are in separate section from USB headers.

@<Header files@>=
#include <avr/io.h>
#include <string.h>

@* Index.
