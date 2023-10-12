Write seconds.

@x
@d serial_port_closed() fd == -1
@d serial_port_opened() fd != -1
@y
@d serial_port_closed() fd == -1 || fd2 == -1
@d serial_port_opened() fd != -1 && fd2 != -1
@z

@x
volatile int fd = -1;
@y
volatile int fd = -1, fd2 = -1;
@z

@x
  if (serial_port_opened()) ioctl(fd, TIOCMSET, &dtr);
@y
  if (serial_port_opened()) ioctl(fd, TIOCMSET, &dtr), ioctl(fd2, TIOCMSET, &dtr);
@z

@x
  if (serial_port_opened()) ioctl(fd, TIOCMSET, &rts);
@y
  if (serial_port_opened()) ioctl(fd, TIOCMSET, &rts), ioctl(fd2, TIOCMSET, &rts);
@z

@x
fd = open("/dev/ttyACM0", O_WRONLY);
@y
{
  if (fd == -1) fd = open("/dev/ttyACM0", O_WRONLY);
  if (fd2 == -1) fd2 = open("/dev/ttyACM1", O_WRONLY);
}
@z

@x
if (write(fd, brightness, 8) == -1)
  close(fd), fd = -1;
@y
if (write(fd, brightness, 8) == -1 || write(fd2, brightness, 8) == -1)
  close(fd), fd = -1, close(fd2), fd2 = -1;
@z

@x
  if (write(fd, ctime(&$) + 11, 8) == -1)
    close(fd), fd = -1;
}
@y
  char *c = ctime(&$) + 11;
  if (write(fd, c, 8) == -1 || write(fd2, c, 8) == -1)
    close(fd), fd = -1, close(fd2), fd2 = -1;
}
@z
