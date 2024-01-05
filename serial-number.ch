@x
void main(void)
{
@y
void main(void)
{
  sn_desc.bLength = sizeof sn_desc;
  sn_desc.bDescriptorType = 0x03;
  U8 addr = DS_START_ADDRESS;
  for (U8 i = 0; i < SN_LENGTH; i++) {
    U8 c = boot_signature_byte_get(addr);
    if (i & 1) { /* we divide each byte of signature into halves, each of
                    which is represented by a hex number */
      c >>= 4;
      addr++;
    }
    else c &= 0x0F;
    sn_desc.wString[i] = (c<10 ? c+'0' : c-10+'A');
  }
@z

@x
  case 0x0200: @/
    @<Handle {\caps get descriptor configuration}@>@;
    break;
@y
  case 0x0200: @/
    @<Handle {\caps get descriptor configuration}@>@;
    break;
  case 0x0300: @/
    @<Handle {\caps get descriptor string} (language)@>@;
    break;
  case 0x0300 | SERIAL_NUMBER: @/
    @<Handle {\caps get descriptor string} (serial)@>@;
    break;
@z

@x
@* USB descriptors.
@y
@ @<Handle {\caps get descriptor string} (language)@>=
(void) UEDATX; @+ (void) UEDATX;
wLength = UEDATX | UEDATX << 8;
UEINTX &= ~_BV(RXSTPI);
buf = &lang_desc; /* 4 bytes */
if (wLength > sizeof lang_desc) size = sizeof lang_desc;
  /* first part of second condition in \S5.5.3 of USB spec */
else size = wLength; /* first condition in \S5.5.3 of USB spec */
while (size) UEDATX = pgm_read_byte(buf++), size--;
UEINTX &= ~_BV(TXINI);
while (!(UEINTX & _BV(RXOUTI))) { }
UEINTX &= ~_BV(RXOUTI);

@ @<Handle {\caps get descriptor string} (serial)@>=
(void) UEDATX; @+ (void) UEDATX;
wLength = UEDATX | UEDATX << 8;
UEINTX &= ~_BV(RXSTPI);
buf = &sn_desc; /* 42 bytes */
if (wLength > sizeof sn_desc) size = sizeof sn_desc;
  /* first part of second condition in \S5.5.3 of USB spec */
else size = wLength; /* first condition in \S5.5.3 of USB spec */
while (size) UEDATX = *(U8 *) buf++, size--;
UEINTX &= ~_BV(TXINI);
while (!(UEINTX & _BV(RXOUTI))) { }
UEINTX &= ~_BV(RXOUTI);

@* USB descriptors.
@z

@x
  0, /* no serial number */
@y
  SERIAL_NUMBER, @/
@z

@x
@* Headers.
@y
@*1 Language descriptor.

@<Global variables@>=
struct {
    U8 bLength;
    U8 bDescriptorType;
    int wString;
} const lang_desc
@t\hskip2.5pt@> @=PROGMEM@> = { @t\1@> @/
  0x04, /* size of this structure */
  0x03, /* string */
@t\2@> 0x0000 /* language id */
};

@*1 Serial number descriptor.

This one is different in that its content cannot be prepared in compile time,
only in execution time. So, it cannot be stored in program memory.

@d SERIAL_NUMBER 1
@d DS_LENGTH 10 /* length of device signature */
@d DS_START_ADDRESS 0x0E
@d SN_LENGTH (DS_LENGTH * 2) /* length of serial number (multiply because each value in hex) */

@<Global variables@>=
struct {
  U8 bLength;
  U8 bDescriptorType;
  int wString[SN_LENGTH];
} sn_desc;

@* Headers.
@z
