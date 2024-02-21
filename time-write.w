@* Intro.

Serial port is done via USB, so it appears and disappears dynamically;
to cope with this, |open| is attempted in a loop and |write| status
is checked and if it failed, |close| is called.

@c
#include <fcntl.h>
#include <time.h>
#include <unistd.h>

void main(int argc, char **argv)
{
  int fd = -1;
  while (1) {
    if (fd == -1)
      @<Try to open serial port@>@;
    if (fd != -1)
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
