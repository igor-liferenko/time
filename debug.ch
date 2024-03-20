stty -F /dev/ttyUSB0 raw 57600; cat /dev/ttyUSB0

@x
  @<Setup USB Controller@>@;
@y
  UBRR1 = 34; // table 18-12 in datasheet
  UCSR1A |= _BV(U2X1);
  UCSR1B |= _BV(TXEN1);
  @<Setup USB Controller@>@;
@z

@x
  UECFG1X = _BV(EPSIZE0) | _BV(EPSIZE1) | _BV(ALLOC); /* 64 bytes */
@y
  UECFG1X = _BV(EPSIZE0) | _BV(EPSIZE1) | _BV(ALLOC); /* 64 bytes */
  if (!(UESTA0X & _BV(CFGOK))) DDRD |= _BV(PD5);
@z

@x
  UDINT &= ~_BV(EORSTI);
@y
  UDINT &= ~_BV(EORSTI);
  tx_char('!');
@z

@x
@* USB connection.
@y
@* USB connection.
@d tx_char(c) do { UDR1 = c; while (!(UCSR1A & _BV(UDRE1))) { } } while (0)
@d HEX(c) tx_char((c)<10 ? (c)+'0' : (c)-10+'A')
@d hex(c) HEX((c >> 4) & 0x0f); HEX(c & 0x0f);
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
  tx_char('%');
  tx_char(' ');
@z

@x set control line state
  UEINTX &= ~_BV(RXSTPI);
@y
  wValue = UEDATX | UEDATX << 8;
  UEINTX &= ~_BV(RXSTPI);
  tx_char('x');
  tx_char('=');
  hex(wValue);
  tx_char(' ');
@z

@x address
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
tx_char('\n');
tx_char('a');
tx_char('=');
hex(wValue);
tx_char(' ');
@z

@x device
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
tx_char('d');
hex(wLength);
if (UDADDR & _BV(ADDEN))
  tx_char(' ');
else {
  tx_char('-');
  tx_char('\n');
}
@z

@x configuration
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
tx_char('c');
hex(wLength);
tx_char(' ');
@z

@x set configuration
UEINTX &= ~_BV(RXSTPI);
@y
UEINTX &= ~_BV(RXSTPI);
tx_char(wValue == CONF_NUM ? 's' : '@@');
tx_char(' ');
@z

@x
UECFG1X = _BV(ALLOC);
@y
UECFG1X = _BV(ALLOC);
if (!(UESTA0X & _BV(CFGOK))) DDRD |= _BV(PD5);
@z

@x
UECFG1X = _BV(ALLOC);
@y
UECFG1X = _BV(ALLOC);
if (!(UESTA0X & _BV(CFGOK))) DDRD |= _BV(PD5);
@z

@x
UECFG1X = _BV(ALLOC);
@y
UECFG1X = _BV(ALLOC);
if (!(UESTA0X & _BV(CFGOK))) DDRD |= _BV(PD5);
@z
