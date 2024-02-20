@* Intro.
NOTE: if you need to use B9600, ignore it first time in device because it is set
automatically by driver when device is connected.

@ @c
#include <fcntl.h>
#include <string.h>
#include <termios.h>

int main(int argc, char **argv)
{
  if (argc != 2) return 1;
  int fd;
  if ((fd = open("/dev/ttyACM0", O_WRONLY)) == -1)
    return 1;
  struct termios tcattr;
  tcgetattr(fd, &tcattr);
  if (strcmp(argv[1], "off") == 0) cfsetspeed(&tcattr, B1200);
  if (strcmp(argv[1], "night") == 0) cfsetspeed(&tcattr, B2400);
  if (strcmp(argv[1], "day") == 0) cfsetspeed(&tcattr, B4800);
  tcsetattr(fd, TCSANOW, &tcattr);
  return 0;
}
