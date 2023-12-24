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
@<Process CONTROL packet@>=
switch (UEDATX | UEDATX << 8) { /* Request and Request Type */
@y
@<Process CONTROL packet@>= {
U16 aa = UEDATX | UEDATX << 8;
switch (aa) { /* Request and Request Type */
@z

@x
  @<Handle {\caps set control line state}@>@;
  break;
@y
  @<Handle {\caps set control line state}@>@;
  break;
default:
  UDR1='?'; while (!(UCSR1A & 1 << UDRE1)) { }
  Hex(aa);
  aa>>=8;
  Hex(aa);
  UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
  UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
}
@z

@x
UEINTX &= ~_BV(RXSTPI);
@y
if (UEINTX & _BV(TXINI)) { UDR1='*'; while (!(UCSR1A & 1 << UDRE1)) { } } /* magic packet? */
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
UDR1='q'; while (!(UCSR1A & 1 << UDRE1)) { } // qualifier
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
UDR1='s'; while (!(UCSR1A & 1 << UDRE1)) { } // serial
Hex(wLength);
if (UDADDR & 0x80) UDR1='+'; else UDR1='-'; while (!(UCSR1A & 1 << UDRE1)) { }  
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~(1 << RXSTPI);
@y
UEINTX &= ~(1 << RXSTPI);
UDR1='z'; while (!(UCSR1A & 1 << UDRE1)) { } // set configuration
if (UDADDR & 0x80) UDR1='+'; else UDR1='-'; while (!(UCSR1A & 1 << UDRE1)) { }  
UDR1='\r'; while (!(UCSR1A & 1 << UDRE1)) { }
UDR1='\n'; while (!(UCSR1A & 1 << UDRE1)) { }
@z

@x
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
UDR1='y'; while (!(UCSR1A & 1 << UDRE1)) { } // set line coding
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
