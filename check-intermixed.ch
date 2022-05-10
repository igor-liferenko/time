If arduino writes to computer (see ~/matrix/), and we do `cat /dev/ttyACM0' from two
different terminal windows, data goes randomly to one of the terminals. But if
we write from computer, it is not clear whether the opposite effect can happen:
when at the same moment bytes ABCDEFGH written to /dev/ttyACM0 in one write() call from process 1
and bytes IJKLMNOP written to /dev/ttyACM0 in one write() call from process 2 can be delivered to
arduino in the order different from ABCDEFGHIJKLMNOP or IJKLMNOPABCDEFGH.
In this change-file we check if such a situation happens, and if it does, we output
99:99 on the display and stop changing it.
This firmware is now only used on `v' with a separate arduino temporarily (on all other arduinos
the firmware from commit b5b63b52 is flashed).
For this on `v' the following changes are made:
  1) in /etc/rc.local simply `time-write &' is used
  2) in cron
     `printf X------- >/dev/ttyACM0' is used instead of `killall -HUP time-write'
     `printf A------- >/dev/ttyACM0' is used instead of `killall -USR1 time-write'
     `printf P------- >/dev/ttyACM0' is used instead of `killall -USR2 time-write'
  3) in change-brightness for `v' the same commands are used as in 2)

I started to use this test from 1 may 2022 - test it for some time and if 99:99 never
appears, reflash all arduinos with current ~/time/ (but without check-intermixed.ch)
and in build scripts for all routers and on routers themselves in cron do the same what is now
on `v' and in change-brightness do the same commands as in 2) for all routers

@x
@<Global variables@>@;
@y
@<Global variables@>@;
uint8_t intermixed = 0;
@z

@x
      UEINTX &= ~(1 << FIFOCON);
@y
      UEINTX &= ~(1 << FIFOCON);
      if (intermixed) continue;
      if ((time[0] >= 'A' && time[0] <= 'P')||(time[0] == 'X')) {
        if (time[7]!='-'||time[6]!='-'||time[5]!='-'||time[4]!='-'||time[3]!='-'||time[2]!='-'||
            time[1]!='-') {
          time[0] = time[1] = time[3] = time[4] = time[6] = time[7] = '9';
          time[2] = time[5] = ':';
          intermixed = 1;
          goto next;
        }
      }
      else {
        if (!(time[0]>='0'&&time[0]<='9')||!(time[1]>='0'&&time[1]<='9')||
            !(time[3]>='0'&&time[3]<='9')||!(time[4]>='0'&&time[4]<='9')||
            !(time[6]>='0'&&time[6]<='9')||!(time[7]>='0'&&time[7]<='9')||
            time[2]!=':'||time[5]!=':') {
          time[0] = time[1] = time[3] = time[4] = time[6] = time[7] = '9';
          time[2] = time[5] = ':';
          intermixed = 1;
          goto next;
        }
      }
@z

@x
      if (time[0] == 'X') glowing = 0;
@y
      if (time[0] == 'X') glowing = 0;
      next:
@z
