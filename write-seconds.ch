@x
@d serial_port_closed() fd == -1
@d serial_port_opened() fd != -1
@y
@d serial_port_closed() fd == -1 || fd2 == -1
@d serial_port_opened() fd != -1 && fd2 != -1
@z

@x
  int fd = -1;
@y
  int fd = -1, fd2 = -1;
@z

@x
fd = open("/dev/ttyACM0", O_WRONLY | O_NOCTTY);
@y
fd = open("/dev/ttyACM0", O_WRONLY | O_NOCTTY),
fd2 = open("/dev/ttyACM1", O_WRONLY | O_NOCTTY);
@z

@x
  time_t $ = time(NULL);
  if (write(fd, ctime(&$) + 11, 8) == -1)
    close(fd), fd = -1;
}
@y
  time_t $ = time(NULL);
  char *c = ctime(&$) + 11;
  if (write(fd, c, 8) == -1 || write(fd2, c, 8) == -1)
    close(fd), fd = -1, close(fd2), fd2 = -1;
}
else close(fd), fd = -1, close(fd2), fd2 = -1;
@z
