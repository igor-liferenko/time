@x
  @<Setup USB Controller@>@;
@y
  UBRR1 = 34; // table 18-12 in datasheet
  UCSR1A |= _BV(U2X1);
  UCSR1B |= _BV(TXEN1);
  @<Setup USB Controller@>@;
@z

@x
  UECFG1X |= _BV(EPSIZE0) | _BV(EPSIZE1) | _BV(ALLOC); /* the same as |EP0_SIZE| */
@y
  UECFG1X |= _BV(EPSIZE0) | _BV(EPSIZE1) | _BV(ALLOC); /* the same as |EP0_SIZE| */
  if (!(UESTA0X & _BV(CFGOK))) DDRD |= _BV(PD5);
@z

@x
  UDINT &= ~_BV(EORSTI);
@y
  tx_char('\n');
  tx_char('!');
  tx_char(' ');
  UDINT &= ~_BV(EORSTI);
@z

@x
@* USB connection.
@y
@* USB connection.
@d tx_char(c) UDR1 = c; while (!(UCSR1A & _BV(UDRE1)))
@d HEX(c) tx_char((c)<10 ? (c)+'0' : (c)-10+'a')
@d hex(c) HEX((c >> 4) & 0x0f); HEX(c & 0x0f)
@z

@x
    UEINTX &= ~_BV(RXSTPI);
@y
    UEINTX &= ~_BV(RXSTPI);
    tx_char('?');
    tx_char(' ');
@z

@x set line coding
  UEINTX &= ~_BV(RXSTPI);
@y
  UEINTX &= ~_BV(RXSTPI);
  tx_char('G');
  tx_char(' ');
@z

@x set control line state
  UEINTX &= ~_BV(RXSTPI);
@y
  wValue = UEDATX | UEDATX << 8;
  UEINTX &= ~_BV(RXSTPI);
  tx_char('E');
  tx_char('=');
  hex(wValue);
  tx_char(' ');
@z

@x address
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
tx_char('A');
tx_char('=');
hex(wValue);
tx_char(' ');
@z

@x device
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
tx_char('D');
hex(wLength);
tx_char(' ');
@z

@x configuration
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
tx_char('C');
hex(wLength);
tx_char(' ');
@z

@x set configuration
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
tx_char(wValue == CONF_NUM ? '*' : '#');
tx_char(' ');
@z

@x
UECFG1X |= _BV(ALLOC);
@y
UECFG1X |= _BV(ALLOC);
if (!(UESTA0X & _BV(CFGOK))) DDRD |= _BV(PD5);
@z

@x
UECFG1X |= _BV(ALLOC);
@y
UECFG1X |= _BV(ALLOC);
if (!(UESTA0X & _BV(CFGOK))) DDRD |= _BV(PD5);
@z

@x
UECFG1X |= _BV(ALLOC);
@y
UECFG1X |= _BV(ALLOC);
if (!(UESTA0X & _BV(CFGOK))) DDRD |= _BV(PD5);
@z
