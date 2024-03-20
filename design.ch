All endpoints are destroyed by USB_RESET.
This fact was determined by checking that EPEN
and ALLOC are disabled, before setting them for each endpoint
(LED would be on if either of them was enabled).

It is good that all endpoints (except 0) are destroyed by USB_RESET,
because we can unconditionally create them in set_configuration.

It is bad that endpoint 0 is destroyed by USB_RESET,
because we cannot create endpoint 0 before attach.

TODO: temporarily add debug.ch to Makefile, uncomment changes here
and ensure that yy is printed for all endpoints
and delete the uncommented changes

@x
  UENUM = 0;
  UECONX |= _BV(EPEN);
@y
  UENUM = 0;
  if (UECONX & _BV(EPEN) || UECONX & _BV(EPEN)) DDRD |= _BV(PD5);
  UECONX |= _BV(EPEN);
@z

 @x
  UECFG1X = _BV(EPSIZE0) | _BV(EPSIZE1) | _BV(ALLOC); /* 64 bytes */
 @y
  UECFG1X = _BV(EPSIZE0) | _BV(EPSIZE1) | _BV(ALLOC); /* 64 bytes */
  tx_char('(');
  tx_char(UECONX & _BV(EPEN) ? 'y' : 'n');
  tx_char(UECFG1X & _BV(ALLOC) ? 'y' : 'n');
  tx_char(')');
 @z

@x
UENUM = 3;
UECONX |= _BV(EPEN);
@y
UENUM = 3;
if (UECONX & _BV(EPEN) || UECONX & _BV(EPEN)) DDRD |= _BV(PD5);
UECONX |= _BV(EPEN);
@z

 @x
UECFG1X = _BV(ALLOC);
 @y
UECFG1X = _BV(ALLOC);
tx_char('(');
tx_char(UECONX & _BV(EPEN) ? 'y' : 'n');
tx_char(UECFG1X & _BV(ALLOC) ? 'y' : 'n');
tx_char(')');
 @z

@x
UENUM = 1;
UECONX |= _BV(EPEN);
@y
UENUM = 1;
if (UECONX & _BV(EPEN) || UECONX & _BV(EPEN)) DDRD |= _BV(PD5);
UECONX |= _BV(EPEN);
@z

 @x
UECFG1X = _BV(ALLOC);
 @y
UECFG1X = _BV(ALLOC);
tx_char('(');
tx_char(UECONX & _BV(EPEN) ? 'y' : 'n');
tx_char(UECFG1X & _BV(ALLOC) ? 'y' : 'n');
tx_char(')');
 @z

@x
UENUM = 2;
UECONX |= _BV(EPEN);
@y
UENUM = 2;
if (UECONX & _BV(EPEN) || UECONX & _BV(EPEN)) DDRD |= _BV(PD5);
UECONX |= _BV(EPEN);
@z

 @x
UECFG1X = _BV(ALLOC);
 @y
UECFG1X = _BV(ALLOC);
tx_char('(');
tx_char(UECONX & _BV(EPEN) ? 'y' : 'n');
tx_char(UECFG1X & _BV(ALLOC) ? 'y' : 'n');
tx_char(')');
 @z
