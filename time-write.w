@* Intro.

TTY device is done via USB, so it appears and disappears dynamically;
to cope with this, |open| is attempted in a loop and |write| status
is checked and if it failed, |close| is called.

TTY device file must not be created if it does not
already exist. Therefore |open|
syscall is without |O_CREAT|.

@c
#include <fcntl.h>
#include <time.h>
#include <unistd.h>

void main(void)
{
  int fd = -1;
  while (1) {
    if (fd == -1)
      fd = open("/dev/ttyACM0", O_WRONLY);
    if (fd != -1) {
      time_t $ = time(NULL);
      if (write(fd, ctime(&$) + 11, 8) == -1)
        close(fd), fd = -1;
    }
    sleep(1);
  }
}
