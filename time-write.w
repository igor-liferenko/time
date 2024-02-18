@* Intro.

@c
@<Header files@>@;

int fd;

int main(int argc, char **argv)
{
  @<Open serial port@>@;
  while (1) {
    @<Write time to serial port@>@;
    sleep(1);
  }
  return 0;
}

@ @<Open serial port@>=
if ((fd = open("/dev/ttyACM0", O_WRONLY)) == -1)
  return 1;

@ @<Write time to serial port@>= {
  time_t $ = time(NULL);
  if (write(fd, ctime(&$) + 11, 8) == -1)
    return 1;
}

@ @<Header files@>=
#include <fcntl.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
