@* Intro.

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
    cfsetspeed(&tcattr, B50), tcattr.c_cflag &= ~CSTOPB;
  else if (strcmp(argv[1], "night") == 0)
    cfsetspeed(&tcattr, B75), tcattr.c_cflag &= ~CSTOPB;
  else if (strcmp(argv[1], "day") == 0)
    cfsetspeed(&tcattr, B75), tcattr.c_cflag |= CSTOPB;
  else return 1;
  tcsetattr(fd, TCSANOW, &tcattr);
  return 0;
}
