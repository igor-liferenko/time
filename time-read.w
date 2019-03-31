\let\lheader\rheader
%\datethis
\secpagedepth=2 % begin new page only on *
\font\caps=cmcsc10 at 9pt

@* Program.

@c
@<Header files@>@;
@<Type definitions@>@;
@<Global variables@>@;
@<Create ISR for connecting to USB host@>@;

void main(void)
{
  @<Connect to USB host (must be called first; |sei| is called here)@>@;
  init_MAX();
  while (1) {
    @<If there is a request on |EP0|, handle it@>@;
    UENUM = EP2;
    if (UEINTX & 1 << RXOUTI) {
      UEINTX &= ~(1 << RXOUTI);
      int rx_counter = UEBCLX;
      char s[10];
      int i = 0;
      while (rx_counter--)
        s[i++] = UEDATX;
      UEINTX &= ~(1 << FIFOCON);
      s[5]='\0';
      if (strcmp(s,"06:00")==0) {
        SLAVE_SELECT;
        for (int i = 0; i < NUM_DEVICES; i++)
          writeWord(0x0A, 0x0F);
        SLAVE_DESELECT;
      }
      if (strcmp(s,"21:00")==0) {
        SLAVE_SELECT;
        for (int i = 0; i < NUM_DEVICES; i++)
          writeWord(0x0A, 0x05);
        SLAVE_DESELECT;
      }
      display_MAX(s);
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
#include "max.h"

@* Index.
