Use ch-file to keep notification endpoint out of main program.

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
255

@ \S22.6 in datasheet.

@<Configure EP3@>=
UENUM = 3;
UECONX |= _BV(EPEN);
UECFG0X |= _BV(EPTYPE0) | _BV(EPTYPE1) | _BV(EPDIR);
UECFG1X |= _BV(ALLOC);

@*3 Data Class Interface descriptor.
@z
