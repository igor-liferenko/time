%outputtemplate:="%j.eps"; prologues:=3;

input rboxes;

verbatimtex
\font\big=cmss17
\font\tenss=cmss10 \tenss
\font\smallss=cmss8 scaled 400
\font\eightss=cmss8
\font\sevenandhalfss=cmss8 scaled 900
\font\sevenss=cmss8 scaled 600
\font\twlss=cmss12
\font\eighttt=cmtt8
etex

vardef cutl(suffix a, b) =
draw a.c -- b.c cutbefore bpath.a cutafter bpath.b;
enddef;

% RULES:
%  1) set wire relative to itself and to connection points (never relative to other wires or elements)
%  2) draw objects in the same place in file where their points are defined
%  3) bind each object to one point with absolute coordinates
%  4) define and draw wires in the end of figure (using "for" loop where applicable) with endpoints being connection points

% TODO: do boxes with 4 corners via "boxit", like "phone" (use "drawboxes(box4); draw pic(box4) shifted (0,-1cm);" to position label not in center)

beginfig(1);

%%%%%%%%% Arduino %%%%%%%%%%%%%
pair arduino[];
arduino1=(-1.3cm,2cm);
arduino2=arduino1+right*3.3cm;
arduino3=arduino2+up*1.5cm;
xpart(arduino4)=xpart(arduino1);
ypart(arduino4)=ypart(arduino3);
% pins
pair arduino.B[],arduino.GND,arduino.VCC,arduino.RST;
xpart(arduino.B2)=xpart(arduino1)+5mm; ypart(arduino.B2)=ypart(arduino1);
xpart(arduino.B3)=xpart(arduino.B2)+3mm; ypart(arduino.B3)=ypart(arduino1);
xpart(arduino.B1)=xpart(arduino.B3)+3mm; ypart(arduino.B1)=ypart(arduino1);
xpart(arduino.VCC)=xpart(arduino.RST)-3mm; ypart(arduino.VCC)=ypart(arduino1);
xpart(arduino.RST)=xpart(arduino.GND)-3mm; ypart(arduino.RST)=ypart(arduino1);
xpart(arduino.GND)=xpart(arduino2)-5mm; ypart(arduino.GND)=ypart(arduino1);
% draw
draw arduino1--arduino2--arduino3--arduino4--cycle;
label(btex \eightss Arduino ProMicro etex, 1/2[arduino1,arduino3]);
begingroup;
save A; pen A; A:=currentpen;
pickup pencircle scaled .4pt;
label.top(btex \smallss 15 etex, arduino.B1);
rboxit.arduino.B1.box(btex \smallss B1 etex);
arduino.B1.box.c=arduino.B1+up*3mm;
arduino.B1.box.sw=arduino.B1.box.c+down*2pt+left*3pt;
drawboxed(arduino.B1.box);
label.top(btex \smallss 14 etex, arduino.B3);
rboxit.arduino.B3.box(btex \smallss B3 etex);
arduino.B3.box.c=arduino.B3+up*3mm;
arduino.B3.box.sw=arduino.B3.box.c+down*2pt+left*3pt;
drawboxed(arduino.B3.box);
label.top(btex \smallss 16 etex, arduino.B2);
rboxit.arduino.B2.box(btex \smallss B2 etex);
arduino.B2.box.c=arduino.B2+up*3mm;
arduino.B2.box.sw=arduino.B2.box.c+down*2pt+left*3pt;
drawboxed(arduino.B2.box);
draw arduino.B2 -- arduino.B2+down*5mm withpen pencircle scaled .4pt;
draw arduino.B3 -- arduino.B3+down*5mm withpen pencircle scaled .4pt;
draw arduino.B1 -- arduino.B1+down*5mm withpen pencircle scaled .4pt;
label.top(btex \smallss VCC etex, arduino.VCC);
draw arduino.VCC -- arduino.VCC+down*5mm withpen pencircle scaled .4pt;
label.top(btex \smallss RST etex, arduino.RST);
label.top(btex \smallss GND etex, arduino.GND);
draw arduino.GND -- arduino.GND+down*5mm withpen pencircle scaled .4pt;
pickup A;
endgroup;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

endfig;

end
