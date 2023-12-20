@x
  @<Setup USB Controller@>@;
@y
  UBRR1 = 34; // table 18-12 in datasheet
  UCSR1A |= 1 << U2X1;
  UCSR1B |= 1 << TXEN1;
  @<Setup USB Controller@>@;
@z

@x
@* Connection protocol.
@y
@* Connection protocol.
@d HEX(c) UDR1 = ((c)<10 ? (c)+'0' : (c)-10+'A'); while (!(UCSR1A & 1 << UDRE1)) { }
@d hex(c) HEX(c >> 4); HEX(c & 0x0f);
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='a'; while (!(UCSR1A & 1 << UDRE1)) { } // address
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='d'; while (!(UCSR1A & 1 << UDRE1)) { } // device
hex(wLength);
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='q'; while (!(UCSR1A & 1 << UDRE1)) { } // qualifier
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='c'; while (!(UCSR1A & 1 << UDRE1)) { } // configuration
hex(wLength);
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='l'; while (!(UCSR1A & 1 << UDRE1)) { } // language
hex(wLength);
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='m'; while (!(UCSR1A & 1 << UDRE1)) { } // manufacturer
hex(wLength);
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='p'; while (!(UCSR1A & 1 << UDRE1)) { } // product
hex(wLength);
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='s'; while (!(UCSR1A & 1 << UDRE1)) { } // serial
hex(wLength);
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='z'; while (!(UCSR1A & 1 << UDRE1)) { } // set configuration
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
while (!(UEINTX & 1 << RXOUTI)) ; /* wait for DATA stage */
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='y'; while (!(UCSR1A & 1 << UDRE1)) { } // set line coding
hex(wLength);
while (!(UEINTX & 1 << RXOUTI)) ; /* wait for DATA stage */
hex(UEBCLX); // check that it is equal to wLength
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
  UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='x'; while (!(UCSR1A & 1 << UDRE1)) { } // set control line state
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z
