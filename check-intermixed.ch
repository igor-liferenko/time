If arduino writes to computer (for example, like in ~/matrix/), and we do `cat /dev/ttyACM0' from
two different terminal windows, data goes to both terminals in a random fashion. But if
we write from computer, it is not clear whether the opposite effect can happen:
when at the same moment bytes ABCDEFGH written to /dev/ttyACM0 in one write() call from process 1
and bytes IJKLMNOP written to /dev/ttyACM0 in one write() call from process 2 can be delivered to
arduino in the order different from ABCDEFGHIJKLMNOP and IJKLMNOPABCDEFGH.
In this change-file we check if such a situation happens, and if it does, we output
99:99 on the display and stop changing the display.
This change-file is now only used on a separate arduino temporarily with `v'.
For this the following changes are made:
  1) on `v' in /etc/rc.local simply `time-write &' is used
  2) on `v' in cron
     `printf X------- >/dev/ttyACM0' is used instead of `killall -HUP time-write'
     `printf A------- >/dev/ttyACM0' is used instead of `killall -USR1 time-write'
     `printf P------- >/dev/ttyACM0' is used instead of `killall -USR2 time-write'
  3) on `f' in change-brightness is done as in 2), but only for `v'

I started to use check-intermixed.ch from 1 may 2022 - test it for some time and if 99:99 never
appears, remove check-intermixed.ch and reflash all arduinos with current ~/time/
and in openwrt/build-{clock,v,t,u}.sh in /etc/rc.local and in cron do as in 1) and 2) and in
openwrt/files/change-brightness do as in 2)
If 99:99 does appear, remove check-intermixed.ch and reflash all arduinos with current ~/time/
and undo the temporary changes on `v' and on `f' and in openwrt/build-{clock,v,t,u}.sh in
/etc/rc.local use the format of brightness-changing commands from 2)

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
