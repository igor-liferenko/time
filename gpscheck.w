@* Intro.
@c
@<Header files@>@;
SIGALRM handler: kill gpspipe, _exit // see git lg time-write
int main(void)
{
  int init = 1;
  pipe();
  if (fork() == 0) {
    dup2 stdout stderr
    exec gpspipe -r
  }
  while (read) { // see tel.w
    if (c == '\n') {
      if (init) {
        init = 0;
        system("clock no-blink");
      }
      alarm(60);
    }
  }
}
@ @<Header files@>=
#include <unistd.h>
