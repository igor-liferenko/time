All endpoints are destroyed by USB_RESET.
This fact was determined by the fact that PD5 is never on.

It is good that all endpoints are destroyed by USB_RESET,
because we can unconditionally create them in set_configuration.

It is bad that endpoint 0 is destroyed by USB_RESET,
because we cannot create endpoint 0 before attach
(which would make it possible not to use ISR).

This ch-file is tested with attach device,
with reboot host and with `sudo usbreset 03eb:2018' (lsusb).

@x
  UENUM = 0;
  UECONX |= _BV(EPEN);
  UECFG1X |= _BV(EPSIZE0) | _BV(EPSIZE1) | _BV(ALLOC); /* 64 bytes */
@y
  UENUM = 0;
  if (UECONX & _BV(EPEN)) DDRD |= _BV(PD5);
  UECONX |= _BV(EPEN);
  if (UECFG1X & _BV(EPSIZE0) || UECFG1X & _BV(EPSIZE1) || UECFG1X & _BV(ALLOC)) DDRD |= _BV(PD5);
  UECFG1X |= _BV(EPSIZE0) | _BV(EPSIZE1) | _BV(ALLOC); /* 64 bytes */
@z

@x
UENUM = 3;
UECONX |= _BV(EPEN);
UECFG0X |= _BV(EPTYPE0) | _BV(EPTYPE1) | _BV(EPDIR);
UECFG1X |= _BV(ALLOC);
@y
UENUM = 3;
if (UECONX & _BV(EPEN)) DDRD |= _BV(PD5);
UECONX |= _BV(EPEN);
if (UECFG0X & _BV(EPTYPE0) || UECFG0X & _BV(EPTYPE1) || UECFG0X & _BV(EPDIR)) DDRD |= _BV(PD5);
UECFG0X |= _BV(EPTYPE0) | _BV(EPTYPE1) | _BV(EPDIR);
if (UECFG1X & _BV(ALLOC)) DDRD |= _BV(PD5);
UECFG1X |= _BV(ALLOC);
@z

@x
UENUM = 1;
UECONX |= _BV(EPEN);
UECFG0X |= _BV(EPTYPE1) | _BV(EPDIR);
UECFG1X |= _BV(ALLOC);
@y
UENUM = 1;
if (UECONX & _BV(EPEN)) DDRD |= _BV(PD5);
UECONX |= _BV(EPEN);
if (UECFG0X & _BV(EPTYPE1)) DDRD |= _BV(PD5);
UECFG0X |= _BV(EPTYPE1) | _BV(EPDIR);
if (UECFG1X & _BV(ALLOC)) DDRD |= _BV(PD5);
UECFG1X |= _BV(ALLOC);
@z

@x
UENUM = 2;
UECONX |= _BV(EPEN);
UECFG0X |= _BV(EPTYPE1);
UECFG1X |= _BV(ALLOC);
@y
UENUM = 2;
if (UECONX & _BV(EPEN)) DDRD |= _BV(PD5);
UECONX |= _BV(EPEN);
if (UECFG0X & _BV(EPTYPE1)) DDRD |= _BV(PD5);
UECFG0X |= _BV(EPTYPE1);
if (UECFG1X & _BV(ALLOC)) DDRD |= _BV(PD5);
UECFG1X |= _BV(ALLOC);
@z
