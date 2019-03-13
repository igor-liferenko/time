\let\lheader\rheader
%\datethis
\secpagedepth=2 % begin new page only on *
\font\caps=cmcsc10 at 9pt

@* Program.

@c
@<Header files@>@;
@<Type \null definitions@>@;
@<Global variables@>@;

@<Create ISR for connecting to USB host@>@;
void main(void)
{
  @<Connect to USB host (must be called first; |sei| is called here)@>@;
  @#
  UBRR1 = 34; /* UART is the simplest testing method, use `\.{cu -l /dev/ttyUSB0 -s 57600}' */
  UCSR1A |= 1 << U2X1;
  UCSR1B |= 1 << TXEN1;
  @#
  while (1) {
    @<If there is a request on |EP0|, handle it@>@;
    UENUM = EP2;
    if (UEINTX & 1 << RXOUTI) {
      UEINTX &= ~(1 << RXOUTI);
      int rx_counter = UEBCLX;
      while (rx_counter--) {
        UDR1 = UEDATX; @+ while (!(UCSR1A & 1 << UDRE1)) ; /* write, then wait */
      }
      UDR1 = '\r'; @+ while (!(UCSR1A & 1 << UDRE1)) ; /* `\.{\\r}' is output only with UART */
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
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <avr/boot.h> /* |boot_signature_byte_get| */
#define F_CPU 16000000UL

@* Index.
