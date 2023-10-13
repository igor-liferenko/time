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

volatile int fd = -1;

void handler1(int signum)
{
  int dtr = TIOCM_DTR;
  if (serial_port_opened()) ioctl(fd, TIOCMSET, &dtr);
}
void handler2(int signum)
{
  int rts = TIOCM_RTS;
  if (serial_port_opened()) ioctl(fd, TIOCMSET, &rts);
}

void main(int argc, char **argv)
{
  struct sigаction sa;
  sigemptyset(&sa.sa_mask);
  sa.sa_flags = 0;

  sa.sa_handler = handler1;
  sigaction(SIGUSR1, &sa, NULL);

  sa.sa_handler = handler2;
  sigaction(SIGUSR2, &sa, NULL);

  bool init = 1;
  char brightness[8] = {'A'};
  if (argc == 2) brightness[1] = atoi(argv[1]);
  else init = 0;
  while (1) {
    if (serial_port_closed())
      @<Try to open serial port@>@;
    if (serial_port_opened()) {
      if (init) {
        init = 0;
        @<Write brightness to serial port@>@;
      }
      else
        @<Write time to serial port@>@;
    }
    sleep(1);
  }
}

@ @<Try to open serial port@>=
fd = open("/dev/ttyACM0", O_WRONLY);

@ @<Write brightness to serial port@>=
if (write(fd, brightness, 8) == -1)
  close(fd), fd = -1;

@ @<Write time to serial port@>= {
  time_t $ = time(NULL);
  if (write(fd, ctime(&$) + 11, 8) == -1)
    close(fd), fd = -1;
}

@ @<Header files@>=
#include <fcntl.h>
#include <signal.h>
#include <stdbool.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <time.h>
#include <unistd.h>
