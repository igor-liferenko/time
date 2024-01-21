cu -l /dev/ttyUSB0 -s 57600

@x
  @<Setup USB Controller@>@;
@y
  UBRR1 = 34; // table 18-12 in datasheet
  UCSR1A |= _BV(U2X1);
  UCSR1B |= _BV(TXEN1);
  @<Setup USB Controller@>@;
@z

@x
  UDINT &= ~_BV(EORSTI);
@y
  UDINT &= ~_BV(EORSTI);
  q_c = 0;
  UDR1 = '!'; while (!(UCSR1A & _BV(UDRE1))) { }
@z

@x
  UECFG1X |= _BV(ALLOC);
@y
  UECFG1X |= _BV(ALLOC);
  if (!(UESTA0X & _BV(CFGOK))) {
    cli();
    UDR1='0'; while (1) { }
  }
@z

@x
@* USB connection.
@y
@ @<Global...@>=U8 q_c;
@* USB connection.
@d HEX(c) UDR1 = ((c)<10 ? (c)+'0' : (c)-10+'A'); while (!(UCSR1A & _BV(UDRE1))) { }
@d hex(c) HEX((c >> 4) & 0x0f); HEX(c & 0x0f);
@z

@x
  default: @/
@y
  case 0x0600: /* get descriptor device qualifier */
@z

@x
  }
@y
    UDR1='.'; while (!(UCSR1A & _BV(UDRE1))) { }
    if (++q_c == 3) { UDR1=' '; while (!(UCSR1A & _BV(UDRE1))) { } }
    break;
  default:
    cli();
    UDR1='#'; while (1) { }
  }
@z

@x
default: @/
@y
case 0x2021: /* set line coding (Table 50 in CDC spec) */
@z

@x
}
@y
  UDR1='%'; while (!(UCSR1A & _BV(UDRE1))) { }
  UDR1=' '; while (!(UCSR1A & _BV(UDRE1))) { }
  break;
default:
  cli();
  UDR1='*'; while (1) { }
}
@z

@x
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
UDR1='\r'; while (!(UCSR1A & _BV(UDRE1))) { }
UDR1='\n'; while (!(UCSR1A & _BV(UDRE1))) { }
UDR1='a'; while (!(UCSR1A & _BV(UDRE1))) { } // address
UDR1='='; while (!(UCSR1A & _BV(UDRE1))) { }
hex(wValue);
UDR1=' '; while (!(UCSR1A & _BV(UDRE1))) { }
@z

@x
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
UDR1='d'; while (!(UCSR1A & _BV(UDRE1))) { } // device
hex(wLength);
if (UDADDR & _BV(ADDEN)) {
  UDR1=' '; while (!(UCSR1A & _BV(UDRE1))) { }
}
else {
  UDR1='-'; while (!(UCSR1A & _BV(UDRE1))) { }
  UDR1='\r'; while (!(UCSR1A & _BV(UDRE1))) { }
  UDR1='\n'; while (!(UCSR1A & _BV(UDRE1))) { }
}
@z

@x
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
UDR1='c'; while (!(UCSR1A & _BV(UDRE1))) { } // configuration
hex(wLength);
UDR1=' '; while (!(UCSR1A & _BV(UDRE1))) { }
@z

@x
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
UDR1='s'; while (!(UCSR1A & _BV(UDRE1))) { } // set configuration
UDR1='='; while (!(UCSR1A & _BV(UDRE1))) { }
hex(wValue);
UDR1=' '; while (!(UCSR1A & _BV(UDRE1))) { }
@z

@x
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
UDR1='\r'; while (!(UCSR1A & _BV(UDRE1))) { }
UDR1='\n'; while (!(UCSR1A & _BV(UDRE1))) { }
UDR1='x'; while (!(UCSR1A & _BV(UDRE1))) { } // set control line state
UDR1='='; while (!(UCSR1A & _BV(UDRE1))) { }
hex(wValue);
UDR1=' '; while (!(UCSR1A & _BV(UDRE1))) { }
@z

@x
UECFG1X |= _BV(ALLOC);
@y
UECFG1X |= _BV(ALLOC);
if (!(UESTA0X & _BV(CFGOK))) {
  cli();
  UDR1='3'; while (1) { }
}
@z

@x
UECFG1X |= _BV(ALLOC);
@y
UECFG1X |= _BV(ALLOC);
if (!(UESTA0X & _BV(CFGOK))) {
  cli();
  UDR1='1'; while (1) { }
}
@z

@x
UECFG1X |= _BV(ALLOC);
@y
UECFG1X |= _BV(ALLOC);
if (!(UESTA0X & _BV(CFGOK))) {
  cli();
  UDR1='2'; while (1) { }
}
@z
