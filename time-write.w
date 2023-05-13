\noinx
@* Intro.
Serial port is done via USB, so it appears and disappears dynamically;
to cope with this, |open| is attempted in a loop and |write| status
is checked and if it failed, |close| is called.

TTY device file must not be created if it does not
already exist. This is similar to `\.{cat >}', but |open|
syscall is without |O_CREAT|.

@d serial_port_closed() fd == -1
@d serial_port_opened() fd != -1

@c
@<Header files@>@;

void main(void)
{
  int fd = -1;
  while (1) {
    if (serial_port_closed())
      @<Try to open serial port@>@;
    if (serial_port_opened())
      @<Write time to serial port@>@;
    sleep(1);
  }
}

@ @<Try to open serial port@>=
fd = open("/dev/ttyACM0", O_WRONLY);

@ @<Write time to serial port@>= {
  time_t $ = time(NULL);
  if (write(fd, ctime(&$) + 11, 8) == -1)
    close(fd), fd = -1;
}

@ @<Header files@>=
#include <fcntl.h>
#include <time.h>
#include <unistd.h>
