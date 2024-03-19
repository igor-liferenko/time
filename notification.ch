Notification endpoint is optional, but without it driver does not work.
So we use ch-file to keep the endpoint out of main
program - as if it is not used.

@x
  UENUM = 2;
  UECONX &= ~_BV(EPEN);
  UECFG1X &= ~_BV(ALLOC);
@y
  UENUM = 2;
  UECONX &= ~_BV(EPEN);
  UECFG1X &= ~_BV(ALLOC);

  UENUM = 3;
  UECONX &= ~_BV(EPEN);
  UECFG1X &= ~_BV(ALLOC);
@z

@x
  @<Configure EP2@>@;
@y
  @<Configure EP2@>@;
  @<Configure EP3@>@;
@z

@x
  @<Union functional descriptor@>@;
@y
  @<Union functional descriptor@>@;
  @<Endpoint descriptor@>@;
@z

@x
  @<Initialize Data Class Interface descriptor@>, @/
@y
  @<Initialize EP3 descriptor@>, @/
  @<Initialize Data Class Interface descriptor@>, @/
@z

@x
0, /* no endpoints */
@y
1, /* one endpoint (notification) */
@z

@x
@*3 Data Class Interface descriptor.
@y
@*3 EP3 descriptor.

\S9.6.6 in USB spec.

@<Initialize EP3 descriptor@>=
SIZEOF_THIS, @/ 
5, /* ENDPOINT */
3 | 1 << 7, @/
0x03, @/
8, @/
0xFF

@ @<Configure EP3@>=
UENUM = 3;
UECONX |= _BV(EPEN);
UECFG0X = _BV(EPTYPE0) | _BV(EPTYPE1) | _BV(EPDIR);
UECFG1X = _BV(ALLOC);

@*3 Data Class Interface descriptor.
@z
