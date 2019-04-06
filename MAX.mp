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

beginfig(1);

boxit.arduino(btex \eightss Arduino ProMicro etex);
arduino.sw=(-1.3cm,2cm);
arduino.e-arduino.w=right*3.3cm;
arduino.n-arduino.s=up*1.5cm;
drawboxed(arduino);

% pins
pair arduino.B[],arduino.GND,arduino.VCC,arduino.RST;
xpart(arduino.B2)=xpart(arduino.w)+5mm; ypart(arduino.B2)=ypart(arduino.s);
xpart(arduino.B3)=xpart(arduino.B2)+3mm; ypart(arduino.B3)=ypart(arduino.s);
xpart(arduino.B1)=xpart(arduino.B3)+3mm; ypart(arduino.B1)=ypart(arduino.s);
xpart(arduino.VCC)=xpart(arduino.RST)-3mm; ypart(arduino.VCC)=ypart(arduino.s);
xpart(arduino.RST)=xpart(arduino.GND)-3mm; ypart(arduino.RST)=ypart(arduino.s);
xpart(arduino.GND)=xpart(arduino.e)-5mm; ypart(arduino.GND)=ypart(arduino.s);
% draw
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
label.top(btex \smallss RST etex, arduino.RST);
label.top(btex \smallss GND etex, arduino.GND);
label.bot(btex \smallss DIN etex, arduino.B2+down*5mm);
label.bot(btex \smallss CS etex, arduino.B3+down*5mm);
label.bot(btex \smallss CLK etex, arduino.B1+down*5mm);
pickup A;
endgroup;

endfig;

beginfig(2);
boxit.arduino(btex \eightss Arduino Micro etex);
arduino.c=(-3cm,0);
arduino.e-arduino.w=right*4cm;
arduino.n-arduino.s=up*1.4cm;
drawboxes(arduino); draw pic(arduino) shifted (up*2mm+left*6mm);
% pins
pair arduino.B[],arduino.D[],arduino.C[];
arduino.B7=arduino.se+left*4.25mm;
arduino.B6=arduino.B7+left*2.5mm;
arduino.B5=arduino.B6+left*2.5mm;
arduino.B4=arduino.B5+left*2.5mm;
arduino.B2=arduino.sw+right*1.75mm;
arduino.D3=arduino.B2+right*5mm;
arduino.D2=arduino.D3+right*2.5mm;
arduino.D1=arduino.D2+right*7.5mm;
% draw
begingroup;
save A; pen A; A:=currentpen;
pickup pencircle scaled .4pt;
boxit.arduino.B0.box(btex \smallss B0 etex);
arduino.B0.box.c=arduino.e+left*5mm;
arduino.B0.box.sw=arduino.B0.box.c+down*2pt+left*3pt; % TODO: use sw and ne corners to specify full width and height, like in setup-tarif.mp, use rbox_radius, use thinner line for drawing the box
drawboxed(arduino.B0.box);
boxit.arduino.D5.box(btex \smallss D5 etex);
arduino.D5.box.c=arduino.B0.box.c+left*3mm;
arduino.D5.box.sw=arduino.D5.box.c+down*2pt+left*3pt;
drawboxed(arduino.D5.box);
boxit.arduino.C7.box(btex \smallss C7 etex);
arduino.C7.box.c=arduino.D5.box.c+left*3mm;
arduino.C7.box.sw=arduino.C7.box.c+down*2pt+left*3pt;
drawboxed(arduino.C7.box);
label.top(btex \smallss 11 etex, arduino.B7);
rboxit.arduino.B7.box(btex \smallss B7 etex);
arduino.B7.box.c=arduino.B7+up*3mm;
arduino.B7.box.sw=arduino.B7.box.c+down*2pt+left*3pt;
drawboxed(arduino.B7.box);
label.top(btex \smallss 10 etex, arduino.B6);
rboxit.arduino.B6.box(btex \smallss B6 etex);
arduino.B6.box.c=arduino.B6+up*3mm;
arduino.B6.box.sw=arduino.B6.box.c+down*2pt+left*3pt;
drawboxed(arduino.B6.box);
label.top(btex \smallss 9 etex, arduino.B5);
rboxit.arduino.B5.box(btex \smallss B5 etex);
arduino.B5.box.c=arduino.B5+up*3mm;
arduino.B5.box.sw=arduino.B5.box.c+down*2pt+left*3pt;
drawboxed(arduino.B5.box);
label.top(btex \smallss 8 etex, arduino.B4);
rboxit.arduino.B4.box(btex \smallss B4 etex);
arduino.B4.box.c=arduino.B4+up*3mm;
arduino.B4.box.sw=arduino.B4.box.c+down*2pt+left*3pt;
drawboxed(arduino.B4.box);
label.top(btex \smallss MOSI etex, arduino.B2);
rboxit.arduino.B2.box(btex \smallss B2 etex);
arduino.B2.box.c=arduino.B2+up*3mm;
arduino.B2.box.sw=arduino.B2.box.c+down*2pt+left*3pt;
drawboxed(arduino.B2.box);
label.top(btex \smallss TX etex, arduino.D3);
rboxit.arduino.D3.box(btex \smallss D3 etex);
arduino.D3.box.c=arduino.D3+up*3mm;
arduino.D3.box.sw=arduino.D3.box.c+down*2pt+left*3pt;
drawboxed(arduino.D3.box);
label.top(btex \smallss RX etex, arduino.D2);
rboxit.arduino.D2.box(btex \smallss D2 etex);
arduino.D2.box.c=arduino.D2+up*3mm;
arduino.D2.box.sw=arduino.D2.box.c+down*2pt+left*3pt;
drawboxed(arduino.D2.box);
label.top(btex \smallss 2 etex, arduino.D1);
rboxit.arduino.D1.box(btex \smallss D1 etex);
arduino.D1.box.c=arduino.D1+up*3mm;
arduino.D1.box.sw=arduino.D1.box.c+down*2pt+left*3pt;
drawboxed(arduino.D1.box);
pickup A;
endgroup;

endfig;

end
