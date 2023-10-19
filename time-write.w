@* Intro.

@c
@<Header files@>@;

int fd;

int main(int argc, char **argv)
{
  if (argc == 1) return 2;
  @<Open serial port@>@;
  @<Write args to serial port@>@;
  while (1) {
    @<Write time to serial port@>@;
    sleep(1);
  }
  return 0;
}

@ @<Open serial port@>=
if ((fd = open("/dev/ttyACM0", O_WRONLY)) == -1)
  return 1;

@ @<Write args to serial port@>=
char args[8] = {'A'};
args[1] = atoi(argv[1]);
if (argc == 3) args[7] = 'B';
if (write(fd, args, 8) == -1)
  return 1;

@ @<Write time to serial port@>= {
  time_t $ = time(NULL);
  if (write(fd, ctime(&$) + 11, 8) == -1)
    return 1;
}

@ @<Header files@>=
//#include <fcntl.h>
//#include <stdlib.h>
//#include <time.h>
//#include <unistd.h>
