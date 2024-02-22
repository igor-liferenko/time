IN endpoint is optional, but without it driver does not work.
So we use ch-file to keep the endpoint out of main
program - as if it is not used.

@x
  UENUM = 2;
  UECONX &= ~_BV(EPEN);
  UECFG1X &= ~_BV(ALLOC);
@y
  UENUM = 1;
  UECONX &= ~_BV(EPEN);
  UECFG1X &= ~_BV(ALLOC);

  UENUM = 2;
  UECONX &= ~_BV(EPEN);
  UECFG1X &= ~_BV(ALLOC);
@z

@x
  @<Configure EP2@>@;
@y
  @<Configure EP1@>@;
  @<Configure EP2@>@;
@z

@x
  @<Endpoint descriptor@>@;
@y
  @<Endpoint descriptor@>@;
  @<Endpoint descriptor@>@;
@z

@x
@t\2@> @<Initialize EP2 descriptor@> @/
@y
  @<Initialize EP1 descriptor@>, @/
@t\2@> @<Initialize EP2 descriptor@> @/
@z

@x
1, /* one endpoint (OUT) */
@y
2, /* two endpoints (IN and OUT) */
@z

@x
@*4 EP2 descriptor.
@y
@*4 EP1 descriptor.

@<Initialize EP1 descriptor@>=
SIZEOF_THIS, @/ 
5, /* ENDPOINT */
1 | 1 << 7, @/
0x02, @/
8, @/
0

@ @<Configure EP1@>=
UENUM = 1;
UECONX |= _BV(EPEN);
UECFG0X = _BV(EPTYPE1) | _BV(EPDIR);
UECFG1X = 0;
UECFG1X |= _BV(ALLOC);

@*4 EP2 descriptor.
@z
