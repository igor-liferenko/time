@x
@d serial_port_opened() fd != -1
@y
@d serial_port_opened() fd != -1 && fd2 != -1
@z

@x
  int fd = -1;
@y
  int fd = -1, fd2;
@z

@x
        @<Write time to serial port@>@;     
    }
@y
        @<Write time to serial port@>@;
    }
    else close(fd), fd = -1, close(fd2);
@z

@x
fd = open("/dev/ttyACM0", O_WRONLY);
@y
fd = open("/dev/ttyACM0", O_WRONLY),
fd2 = open("/dev/ttyACM1", O_WRONLY);
@z

@x
if (write(fd, brightness, 8) == -1)
  close(fd), fd = -1;
@y
if (write(fd, brightness, 8) == -1 || write(fd2, brightness, 8) == -1)
  close(fd), fd = -1, close(fd2);
@z

@x
  if (write(fd, ctime(&$) + 11, 8) == -1)
    close(fd), fd = -1;
}
@y
  char *c = ctime(&$) + 11;
  if (write(fd, c, 8) == -1 || write(fd2, c, 8) == -1)
    close(fd), fd = -1, close(fd2);
}
@z
