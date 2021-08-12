@x
  int fd = -1;
@y
  int fd = -1, fd2 = -1;
@z

@x
fd = open("/dev/ttyACM0", O_WRONLY | O_NOCTTY);
@y
fd = open("/dev/ttyACM0", O_WRONLY | O_NOCTTY);
fd2 = open("/dev/ttyACM1", O_WRONLY | O_NOCTTY);      
if (fd == -1 || fd2 == -1) {
  close(fd); close(fd2);
  fd = -1; fd2 = -1;
}
@z

@x
  if (write(fd, ctime(&$) + 11, 8) == -1) {
    close(fd);
    fd = -1;
  }
@y
  char *c = ctime(&$) + 11;
  errno = 0;
  write(fd, c, 8); write(fd2, c, 8);
  if (errno) {
    close(fd); close(fd2);
    fd = -1; fd2 = -1;
  }
@z

@x
@ @<Header files@>=
@y
@ @<Header files@>=
#include <errno.h>
@z
