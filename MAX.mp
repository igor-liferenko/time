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

end
