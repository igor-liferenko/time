@* Intro.

@c
#include <fcntl.h>
#include <termios.h>

int main(int argc, char **argv)
{
  if (argc != 2) return 1;
  int fd;
  if ((fd = open("/dev/ttyACM0", O_WRONLY)) == -1) return 1;
  struct termios tcattr;
  tcgetattr(fd, &tcattr);
  switch (*argv[1])
  {
  case '0':
    cfsetspeed(&tcattr, B75), tcattr.c_cflag &= ~CSTOPB;
    break;
  case '1':
    cfsetspeed(&tcattr, B110), tcattr.c_cflag &= ~CSTOPB;
    break;
  case '2':
    cfsetspeed(&tcattr, B134), tcattr.c_cflag &= ~CSTOPB;
    break;
  case '3':
    cfsetspeed(&tcattr, B150), tcattr.c_cflag &= ~CSTOPB;
    break;
  case '4':
    cfsetspeed(&tcattr, B200), tcattr.c_cflag &= ~CSTOPB;
    break;
  case '5':
    cfsetspeed(&tcattr, B300), tcattr.c_cflag &= ~CSTOPB;
    break;
  case '6':
    cfsetspeed(&tcattr, B600), tcattr.c_cflag &= ~CSTOPB;
    break;
  case '7':
    cfsetspeed(&tcattr, B1200), tcattr.c_cflag &= ~CSTOPB;
    break;
  case '8':
    cfsetspeed(&tcattr, B1800), tcattr.c_cflag &= ~CSTOPB;
    break;
  case '9':
    cfsetspeed(&tcattr, B2400), tcattr.c_cflag &= ~CSTOPB;
    break;
  case 'A':
    cfsetspeed(&tcattr, B4800), tcattr.c_cflag &= ~CSTOPB;
    break;
  case 'B':
    cfsetspeed(&tcattr, B19200), tcattr.c_cflag &= ~CSTOPB;
    break;
  case 'C':
    cfsetspeed(&tcattr, B38400), tcattr.c_cflag &= ~CSTOPB;
    break;
  case 'D':
    cfsetspeed(&tcattr, B57600), tcattr.c_cflag &= ~CSTOPB;
    break;
  case 'E':
    cfsetspeed(&tcattr, B50), tcattr.c_cflag |= CSTOPB;
    break;
  case 'F':
    cfsetspeed(&tcattr, B75), tcattr.c_cflag |= CSTOPB;
    break;
  default:
    cfsetspeed(&tcattr, B50), tcattr.c_cflag &= ~CSTOPB;
  }
  tcsetattr(fd, TCSANOW, &tcattr);
  return 0;
}
