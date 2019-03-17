\let\lheader\rheader
%\datethis
\secpagedepth=2 % begin new page only on *
\font\caps=cmcsc10 at 9pt

@i LCD.w

@* Program.

@c
@<Header files@>@;
@<Type definitions@>@;
@<Global variables@>@;
@<Create ISR for connecting to USB host@>@;

#include "lcd.h";

void main(void)
{
  @<Connect to USB host (must be called first; |sei| is called here)@>@;
  UBRR1 = 34; /* UART is the simplest testing method, use `\.{cu -l /dev/ttyUSB0 -s 57600}' */
  UCSR1A |= 1 << U2X1;
  UCSR1B |= 1 << TXEN1;

  LCD_Init();

  while (1) {
    @<If there is a request on |EP0|, handle it@>@;
    UENUM = EP2;
    if (UEINTX & 1 << RXOUTI) {
      UEINTX &= ~(1 << RXOUTI);
      int rx_counter = UEBCLX;
      LCD_Command(0x01);
      while (rx_counter--) {
        unsigned char x = UEDATX;
        LCD_Char(x == '0' ? 'O' : x);
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

@i ../usb/OUT-endpoint-management.w
@i ../usb/USB.w

@* Headers.
\secpagedepth=1 % index on current page

@<Header files@>=
#include <avr/io.h>
//TODO: move these to USB.w (in matrix and avrtel too):
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <avr/boot.h> /* |boot_signature_byte_get| */

@* Index.
