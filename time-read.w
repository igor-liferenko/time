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
  @<Initialize LCD@>@;
  while (1) {
    @<If there is a request on |EP0|, handle it@>@;
    UENUM = EP2;
    if (UEINTX & 1 << RXOUTI) {
      UEINTX &= ~(1 << RXOUTI);
      @<Clear LCD@>@;
      int rx_counter = UEBCLX;
      while (rx_counter--) {
        @<Display character on LCD@>@;
      }
      UEINTX &= ~(1 << FIFOCON);
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

@* LCD.

@<Header files@>=
#include "lcd.h"

@ @<Initialize LCD@>=
LCD_Init();

@ @<Clear LCD@>=
LCD_Command(0x01);

@ Use the quirk with intermediate variable because the LCD is broken.

@<Display character on LCD@>=
unsigned char x = UEDATX;
LCD_Char(x == '0' ? 'O' : x);

@i ../usb/OUT-endpoint-management.w
@i ../usb/USB.w

@* Headers.
\secpagedepth=1 % index on current page

@<Header files@>=
#include <avr/io.h>

@* Index.
