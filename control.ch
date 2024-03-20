Use ch-file to keep set_control_line_state out of main program.

@x
case 0x0900: @/
  @<Handle {\caps set configuration}@>@;
  break;
@y
case 0x0900: @/
  @<Handle {\caps set configuration}@>@;
  break;
case 0x2221: /* set control line state */
  UEINTX &= ~_BV(RXSTPI);
  UEINTX &= ~_BV(TXINI);
  break;
@z
