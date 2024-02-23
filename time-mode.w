@* Intro.

Do not use |B0|, |B9600| and above |B57600| on host and ignore 9600 on device.

@c
#include <fcntl.h>
#include <string.h>
#include <termios.h>

int main(int argc, char **argv)
{
  if (argc != 2) return 1;
  int fd;
  if ((fd = open("/dev/ttyACM0", O_WRONLY)) == -1) return 1;
  struct termios tcattr;
  tcgetattr(fd, &tcattr);
  if (strcmp(argv[1], "off") == 0)
    cfsetspeed(&tcattr, B50), tcattr.c_cflag &= ~CSTOPB; /* blank - see brigtness.ch */
  else if (strcmp(argv[1], "night") == 0)
    cfsetspeed(&tcattr, B75), tcattr.c_cflag &= ~CSTOPB; /* 0x00 - see brigtness.ch */
  else if (strcmp(argv[1], "day") == 0)
    cfsetspeed(&tcattr, B600), tcattr.c_cflag |= CSTOPB; /* 0x0F - see brigtness.ch */
  else return 1;
  tcsetattr(fd, TCSANOW, &tcattr);
  return 0;
}
