use this change-file with usb commit decd1b4

@x
  @<Setup USB Controller@>@;
@y
  UBRR1 = 34; // table 18-12 in datasheet
  UCSR1A |= 1 << U2X1;
  UCSR1B |= 1 << TXEN1;
  @<Setup USB Controller@>@;
@z

@x
  UDINT &= ~(1 << EORSTI); /* for the interrupt handler to be called for next USB\_RESET */
@y
  UDINT &= ~(1 << EORSTI); /* for the interrupt handler to be called for next USB\_RESET */
  UDR1 = '!'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
@* Connection protocol.
@y
@* Connection protocol.
@d HEX(c) UDR1 = ((c)<10 ? (c)+'0' : (c)-10+'A'); while (!(UCSR1A & 1 << UDRE1)) { }
@d Hex(c) HEX((c >> 4) & 0x0f); HEX(c & 0x0f);
@z

@x
  @<Handle {\caps set control line state}@>@;
  break;
@y
  @<Handle {\caps set control line state}@>@;
  break;
default:
  UDR1='?'; while (1) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='a'; while (!(UCSR1A & 1 << UDRE1)) { } // address
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='d'; while (!(UCSR1A & 1 << UDRE1)) { } // device
Hex(wLength);
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='q'; while (!(UCSR1A & 1 << UDRE1)) { } // qualifier
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='c'; while (!(UCSR1A & 1 << UDRE1)) { } // configuration
Hex(wLength);
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='l'; while (!(UCSR1A & 1 << UDRE1)) { } // language
Hex(wLength);
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='m'; while (!(UCSR1A & 1 << UDRE1)) { } // manufacturer
Hex(wLength);
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='p'; while (!(UCSR1A & 1 << UDRE1)) { } // product
Hex(wLength);
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='s'; while (!(UCSR1A & 1 << UDRE1)) { } // serial
Hex(wLength);
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='z'; while (!(UCSR1A & 1 << UDRE1)) { } // set configuration
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
while (!(UEINTX & 1 << RXOUTI)) ; /* wait for DATA stage */
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='y'; while (!(UCSR1A & 1 << UDRE1)) { } // set line coding
Hex(wLength);
while (!(UEINTX & 1 << RXOUTI)) ; /* wait for DATA stage */
Hex(UEBCLX); // check that it is equal to wLength
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
  UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='x'; while (!(UCSR1A & 1 << UDRE1)) { } // set control line state
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z
