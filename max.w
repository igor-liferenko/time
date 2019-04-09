\let\lheader\rheader
%\datethis
\secpagedepth=2 % begin new page only on *
\font\caps=cmcsc10 at 9pt

@* Program.

$$\hbox to7cm{\vbox to5.55cm{\vfil\special{psfile=max-pic.eps
  clip llx=0 lly=0 urx=431 ury=342 rwi=1984}}\hfil}$$

$$\hbox to7.16cm{\vbox to2.92805555555556cm{\vfil\special{psfile=MAX.1
  clip llx=-63 lly=96 urx=140 ury=179 rwi=2030}}\hfil}$$

@c
@<Header files@>@;
@<Type definitions@>@;
@<Global variables@>@;
@<Create ISR for connecting to USB host@>@;

void main(void)
{
  @<Connect to USB host (must be called first; |sei| is called here)@>@;

  MAX_init();

  while (1) {
    @<If there is a request on |EP0|, handle it@>@;
    UENUM = EP2;
    if (UEINTX & 1 << RXOUTI) {
      UEINTX &= ~(1 << RXOUTI);
      int rx_counter = UEBCLX;
      while (rx_counter--)
        str[7-rx_counter] = UEDATX;
      UEINTX &= ~(1 << FIFOCON);
      if (strcmp(str, "06:00:00") == 0)
        display_write(0x0A << 8 | 0xFF);
      if (strcmp(str, "21:00:00") == 0)
        display_write(0x0A << 8 | 0x01);
      for (int i = 0; i < 8; i++)
        display_write(8-i << 8 | (str[i]==':'?0x0F:str[i]-48));
    }
  }
}

@ @<Global...@>=
char str[9];

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
#include <string.h> /* |strcmp| */
#include "max.h"

@* Index.
