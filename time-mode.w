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
  else if (strcmp(argv[1], "0") == 0)
    cfsetspeed(&tcattr, B75), tcattr.c_cflag &= ~CSTOPB;
  else if (strcmp(argv[1], "1") == 0)
    cfsetspeed(&tcattr, B110), tcattr.c_cflag &= ~CSTOPB;
  else if (strcmp(argv[1], "2") == 0)
    cfsetspeed(&tcattr, B134), tcattr.c_cflag &= ~CSTOPB;
  else if (strcmp(argv[1], "3") == 0)
    cfsetspeed(&tcattr, B150), tcattr.c_cflag &= ~CSTOPB;
  else if (strcmp(argv[1], "4") == 0)
    cfsetspeed(&tcattr, B200), tcattr.c_cflag &= ~CSTOPB;
  else if (strcmp(argv[1], "5") == 0)
    cfsetspeed(&tcattr, B300), tcattr.c_cflag &= ~CSTOPB;
  else if (strcmp(argv[1], "6") == 0)
    cfsetspeed(&tcattr, B600), tcattr.c_cflag &= ~CSTOPB;
  else if (strcmp(argv[1], "7") == 0)
    cfsetspeed(&tcattr, B1200), tcattr.c_cflag &= ~CSTOPB;
  else if (strcmp(argv[1], "8") == 0)
    cfsetspeed(&tcattr, B1800), tcattr.c_cflag &= ~CSTOPB;
  else if (strcmp(argv[1], "9") == 0) 
    cfsetspeed(&tcattr, B2400), tcattr.c_cflag &= ~CSTOPB;  
  else if (strcmp(argv[1], "A") == 0) 
    cfsetspeed(&tcattr, B4800), tcattr.c_cflag &= ~CSTOPB;  
  else if (strcmp(argv[1], "B") == 0) 
    cfsetspeed(&tcattr, B19200), tcattr.c_cflag &= ~CSTOPB;  
  else if (strcmp(argv[1], "C") == 0) 
    cfsetspeed(&tcattr, B38400), tcattr.c_cflag &= ~CSTOPB;  
  else if (strcmp(argv[1], "D") == 0) 
    cfsetspeed(&tcattr, B57600), tcattr.c_cflag &= ~CSTOPB;  
  else if (strcmp(argv[1], "E") == 0)  
    cfsetspeed(&tcattr, B50), tcattr.c_cflag |= CSTOPB;    
  else if (strcmp(argv[1], "F") == 0)
    cfsetspeed(&tcattr, B75), tcattr.c_cflag |= CSTOPB;
  else return 1;
  tcsetattr(fd, TCSANOW, &tcattr);
  return 0;
}
