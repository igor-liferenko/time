cu -l /dev/ttyUSB0 -s 57600 (only RX and GND must be connected to arduino)

@x
  @<Setup USB Controller@>@;
@y
  UBRR1 = 34; // table 18-12 in datasheet
  UCSR1A |= 1 << U2X1;
  UCSR1B |= 1 << TXEN1;
  @<Setup USB Controller@>@;
@z

@x
  UDINT &= ~_BV(EORSTI);
@y
  UDINT &= ~_BV(EORSTI);
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
  default: @/
    UECONX |= _BV(STALLRQ);
    UEINTX &= ~_BV(RXSTPI);
@y
  case 0x0600: /* get descriptor device qualifier */
    UECONX |= _BV(STALLRQ);
    UEINTX &= ~_BV(RXSTPI);
    break;
  default:
    UDR1='#'; while (!(UCSR1A & 1 << UDRE1)) { }
    UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
    UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
default: @/
  UEINTX &= ~_BV(RXSTPI);
  while (!(UEINTX & _BV(RXOUTI))) { }
  UEINTX &= ~_BV(RXOUTI);
  UEINTX &= ~_BV(TXINI);
@y
case 0x2021: /* set line coding */
  UEINTX &= ~_BV(RXSTPI);
  while (!(UEINTX & _BV(RXOUTI))) { }
  UEINTX &= ~_BV(RXOUTI);
  UEINTX &= ~_BV(TXINI);
  UDR1='@@'; while (!(UCSR1A & 1 << UDRE1)) { }
  UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
  UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
  break;
default:
  UDR1='*'; while (!(UCSR1A & 1 << UDRE1)) { }
  UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
  UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
UDR1='a'; while (!(UCSR1A & 1 << UDRE1)) { } // address
UDR1='='; while (!(UCSR1A & 1 << UDRE1)) { }
Hex(wValue);
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
UDR1='d'; while (!(UCSR1A & 1 << UDRE1)) { } // device
Hex(wLength);
if (UDADDR & 0x80) UDR1='+'; else UDR1='-'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='c'; while (!(UCSR1A & 1 << UDRE1)) { } // configuration
Hex(wLength);
if (UDADDR & 0x80) UDR1='+'; else UDR1='-'; while (!(UCSR1A & 1 << UDRE1)) { }  
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
UDR1='l'; while (!(UCSR1A & 1 << UDRE1)) { } // language
Hex(wLength);
if (UDADDR & 0x80) UDR1='+'; else UDR1='-'; while (!(UCSR1A & 1 << UDRE1)) { }  
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
UDR1='n'; while (!(UCSR1A & 1 << UDRE1)) { } // serial number
Hex(wLength);
if (UDADDR & 0x80) UDR1='+'; else UDR1='-'; while (!(UCSR1A & 1 << UDRE1)) { }  
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='s'; while (!(UCSR1A & 1 << UDRE1)) { } // set configuration
if (UDADDR & 0x80) UDR1='+'; else UDR1='-'; while (!(UCSR1A & 1 << UDRE1)) { }  
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
UDR1='x'; while (!(UCSR1A & 1 << UDRE1)) { } // set control line state
if (UDADDR & 0x80) UDR1='+'; else UDR1='-'; while (!(UCSR1A & 1 << UDRE1)) { }  
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z
