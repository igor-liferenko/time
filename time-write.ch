Write seconds.

@x
int fd;
@y
int fd, fd2;
@z

@x
if ((fd = open("/dev/ttyACM0", O_WRONLY)) == -1)
@y
fd = open("/dev/ttyACM0", O_WRONLY);
fd2 = open("/dev/ttyACM1", O_WRONLY);
if (fd == -1 || fd2 == -1) return 1;
@z

@x
if (write(fd, args, 8) == -1)
@y
if (write(fd, args, 8) == -1 || write(fd2, brightness, 8) == -1)
@z

@x
  if (write(fd, ctime(&$) + 11, 8) == -1)
@y
  char *c = ctime(&$) + 11;
  if (write(fd, c, 8) == -1 || write(fd2, c, 8) == -1)
@z
