%TODO: change line_status.DTR to line_status.all
%TODO: change DTR to DTR/RTS
%TODO: rm note about TLP281

\let\lheader\rheader
%\datethis
\secpagedepth=2 % begin new page only on *
\font\caps=cmcsc10 at 9pt

%\let\maybe=\iffalse

@* Program.

@d EP0 0
@d EP1 1
@d EP2 2
@d EP3 3

@d EP0_SIZE 32 /* 32 bytes\footnote\dag{Must correspond to |UECFG1X| of |EP0|.}
                  (max for atmega32u4) */

@c
@<Header files@>@;
typedef unsigned char U8;
typedef unsigned short U16;
@<Type \null definitions@>@;
@<Global variables@>@;


volatile int connected = 0;
void main(void)
{
  @<Disable WDT@>@;
  UHWCON |= 1 << UVREGE;
  USBCON |= 1 << USBE;
  PLLCSR = 1 << PINDIV;
  PLLCSR |= 1 << PLLE;
  while (!(PLLCSR & 1 << PLOCK)) ;
  USBCON &= ~(1 << FRZCLK);
  USBCON |= 1 << OTGPADE;
  UDIEN |= 1 << EORSTE;
  sei();
  UDCON &= ~(1 << DETACH); /* attach after we prepared interrupts, because
    USB\_RESET will arrive only after attach, and before it arrives, all interrupts
    must be already set up; also, there is no need to detect when VBUS becomes
    high ---~USB\_RESET can arrive only after VBUS is operational anyway, and
    USB\_RESET is detected via interrupt */

  while (!connected)
    if (UEINTX & 1 << RXSTPI)
      @<Process SETUP request@>@;
  UENUM = EP2;

  UBRR1 = 34; /* this is the simplest testing method - use `\.{cu -l /dev/ttyUSB0 -s 57600}' */
  UCSR1A |= 1 << U2X1;
  UCSR1B |= 1 << TXEN1;
  while (1) {
    @<Get |line_status|@>@;
    if (UEINTX & 1 << RXOUTI) {
      UEINTX &= ~(1 << RXOUTI);
      int rx_counter = UEBCLX;
      while (rx_counter--) {
        UDR1 = UEDATX; while (!(UCSR1A & 1 << UDRE1)) ; /* write, then wait */
      }
      UDR1 = '\r'; while (!(UCSR1A & 1 << UDRE1)) ; /* `\.{\\r}' is output only with UART */
      UEINTX &= ~(1 << FIFOCON);
    }
  }
}


@ No other requests except {\caps set control line state} come
after connection is established (speed is not set in \.{tel}).

@<Get |line_status|@>=
UENUM = EP0;
if (UEINTX & 1 << RXSTPI) {
  (void) UEDATX; @+ (void) UEDATX;
  @<Handle {\caps set control line state}@>@;
}
UENUM = EP2; /* restore */

@ @<Type \null definitions@>=
typedef union {
  U16 all;
  struct {
    U16 DTR:1;
    U16 RTS:1;
    U16 unused:14;
  };
} S_line_status;

@ @<Global variables@>=
S_line_status line_status;

@ This request generates RS-232/V.24 style control signals.

Only first two bits of the first byte are used. First bit indicates to DCE if DTE is
present or not. This signal corresponds to V.24 signal 108/2 and RS-232 signal DTR.
@^DTR@>
Second bit activates or deactivates carrier. This signal corresponds to V.24 signal
105 and RS-232 signal RTS\footnote*{For some reason on linux DTR and RTS signals
are tied to each other.}. Carrier control is used for half duplex modems.
The device ignores the value of this bit when operating in full duplex mode.

\S6.2.14 in CDC spec.

Here DTR is used by host to say the device not to send when DTR is not active.
@^Hardware flow control@>

@<Handle {\caps set control line state}@>=
wValue = UEDATX | UEDATX << 8;
UEINTX &= ~(1 << RXSTPI);
UEINTX &= ~(1 << TXINI); /* STATUS stage */
line_status.all = wValue;

@ Used in USB\_RESET interrupt handler.
Reset is used to go to beginning of connection loop (because we cannot
use \&{goto} from within interrupt handler). Watchdog reset is used because
in atmega32u4 there is no simpler way to reset MCU.

@<Reset MCU@>=
WDTCSR |= 1 << WDCE | 1 << WDE; /* allow to enable WDT */
WDTCSR = 1 << WDE; /* enable WDT */
while (1) ;

@ When reset is done via watchdog, WDRF (WatchDog Reset Flag) is set in MCUSR register.
WDE (WatchDog system reset Enable) is always set in WDTCSR when WDRF is set. It
is necessary to clear WDE to stop MCU from eternal resetting:
on MCU start we always clear |WDRF| and WDE
(nothing will change if they are not set).
To avoid unintentional changes of WDE, a special write procedure must be followed
to change the WDE bit. To clear WDE, WDRF must be cleared first.

Datasheet says that |WDE| is always set to one when |WDRF| is set to one,
but it does not say if |WDE| is always set to zero when |WDRF| is not set
(by default it is zero).
So we must always clear |WDE| independent of |WDRF|.

This should be done right at the beginning of |main|, in order to be in
time before WDT is triggered.
We don't call \\{wdt\_reset} because initialization code,
that \.{avr-gcc} adds, has enough time to execute before watchdog
timer (16ms in this program) expires:

$$\vbox{\halign{\tt#\cr
  eor r1, r1 (1 cycle)\cr
  out 0x3f, r1 (1 cycle)\cr
  ldi r28, 0xFF (1 cycle)\cr
  ldi r29, 0x0A (1 cycle)\cr
  out 0x3e, r29 (1 cycle)\cr
  out 0x3d, r28 (1 cycle)\cr
  call <main> (4 cycles)\cr
}}$$

At 16MHz each cycle is 62.5 nanoseconds, so it is 7 instructions,
taking 10 cycles, multiplied by 62.5 is 625 nanoseconds.

What the above code does: zero r1 register, clear SREG, initialize program stack
(to the stack processor writes addresses for returning from subroutines and interrupt
handlers). To the stack pointer is written address of last cell of RAM.

Note, that ns is $10^{-9}$, $\mu s$ is $10^{-6}$ and ms is $10^{-3}$.

@<Disable WDT@>=
if (MCUSR & 1 << WDRF) /* takes 2 instructions if |WDRF| is set to one:
    \.{in} (1 cycle),
    \.{sbrs} (2 cycles), which is 62.5*3 = 187.5 nanoseconds
    more, but still within 16ms; and it takes 5 instructions if |WDRF|
    is not set: \.{in} (1 cycle), \.{sbrs} (2 cycles), \.{rjmp} (2 cycles),
    which is 62.5*5 = 312.5 ns more, but still within 16ms */
  MCUSR &= ~(1 << WDRF); /* takes 3 instructions: \.{in} (1 cycle),
    \.{andi} (1 cycle), \.{out} (1 cycle), which is 62.5*3 = 187.5 nanoseconds
    more, but still within 16ms */
if (WDTCSR & 1 << WDE) { /* takes 2 instructions: \.{in} (1 cycle),
    \.{sbrs} (2 cycles), which is 62.5*3 = 187.5 nanoseconds
    more, but still within 16ms */
  WDTCSR |= 1 << WDCE; /* allow to disable WDT (\.{lds} (2 cycles), \.{ori}
    (1 cycle), \.{sts} (2 cycles)), which is 62.5*5 = 312.5 ns more, but
    still within 16ms) */
  WDTCSR = 0x00; /* disable WDT (\.{sts} (2 cycles), which is 62.5*2 = 125 ns more,
    but still within 16ms)\footnote*{`\&=' must not be used here, because
    the following instructions will be used: \.{lds} (2 cycles),
    \.{andi} (1 cycle), \.{sts} (2 cycles), but according to datasheet \S8.2
    this must not exceed 4 cycles, whereas with `=' at most the
    following instructions are used: \.{ldi} (1 cycle) and \.{sts} (2 cycles),
    which is within 4 cycles.} */
}

@ @c
ISR(USB_GEN_vect)
{
  UDINT &= ~(1 << EORSTI); /* for the interrupt handler to be called for next USB\_RESET */
  if (!connected) {
    UECONX |= 1 << EPEN;
    UECFG1X = 1 << EPSIZE1; /* 32 bytes\footnote\ddag{Must correspond to |EP0_SIZE|.} */
    UECFG1X |= 1 << ALLOC;
  }
  else {
    @<Reset MCU@>@;
  }
}

@i ../usb/establishing-usb-connection.w
@i ../usb/CONTROL-endpoint-management.w
@i ../usb/OUT-endpoint-management.w
@i ../usb/usb_stack.w

@* Headers.
\secpagedepth=1 % index on current page

@<Header files@>=
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <avr/boot.h> /* |boot_signature_byte_get| */
#define F_CPU 16000000UL

@* Index.
