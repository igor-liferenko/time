%outputtemplate:="%j.eps"; prologues:=3;

input rboxes;

verbatimtex
\font\big=cmss17
\font\tenss=cmss10 \tenss
etex

beginfig(1);
u:=1.7cm;
boxit.arduino(btex \big Arduino ProMicro etex);
arduino.sw=(-1.3u,2u);
arduino.e-arduino.w=right*4.2u;
arduino.n-arduino.s=up*1.5u;
drawboxes(arduino); draw pic(arduino) shifted (down*.1u);

% pins
pair arduino[],arduino.B[],arduino.E[],arduino.D[],arduino.GND[],arduino.VCC,arduino.RST;
xpart(arduino.16)=xpart(arduino.w)+.57u; ypart(arduino.16)=ypart(arduino.s);
xpart(arduino.14)=xpart(arduino.16)+.45u; ypart(arduino.14)=ypart(arduino.s);
xpart(arduino.15)=xpart(arduino.14)+.45u; ypart(arduino.15)=ypart(arduino.s);
xpart(arduino.VCC)=xpart(arduino.RST)-.48u; ypart(arduino.VCC)=ypart(arduino.s);
xpart(arduino.RST)=xpart(arduino.GND1)-.48u; ypart(arduino.RST)=ypart(arduino.s);
xpart(arduino.GND1)=xpart(arduino.e)-.6u; ypart(arduino.GND1)=ypart(arduino.s);
xpart(arduino.GND2)=xpart(arduino.VCC); ypart(arduino.GND2)=ypart(arduino.n);
xpart(arduino.D7)=xpart(arduino.15); ypart(arduino.D7)=ypart(arduino.n);
xpart(arduino.E6)=xpart(arduino.14); ypart(arduino.E6)=ypart(arduino.n);
xpart(arduino.B4)=xpart(arduino.16); ypart(arduino.B4)=ypart(arduino.n);
% draw
begingroup;
interim rbox_radius:=1bp;
save A; pen A; A:=currentpen;
pickup pencircle scaled .1pt;
label.bot(btex 8 etex, arduino.B4);
rboxit.arduino.B4_box(btex B4 etex);
arduino.B4_box.c=arduino.B4+down*.35u;
arduino.B4_box.ne=arduino.B4_box.sw+right*.3u+up*.2u;
drawboxed(arduino.B4_box);
label.bot(btex 7 etex, arduino.E6);
rboxit.arduino.E6_box(btex E6 etex);
arduino.E6_box.c=arduino.E6+down*.35u;
arduino.E6_box.ne=arduino.E6_box.sw+right*.3u+up*.2u;
drawboxed(arduino.E6_box);
label.bot(btex 6 etex, arduino.D7);
rboxit.arduino.D7_box(btex D7 etex);
arduino.D7_box.c=arduino.D7+down*.35u;
arduino.D7_box.ne=arduino.D7_box.sw+right*.3u+up*.2u;
drawboxed(arduino.D7_box);
label.bot(btex GND etex, arduino.GND2);
label.top(btex 15 etex, arduino.15);
label.top(btex 14 etex, arduino.14);
label.top(btex 16 etex, arduino.16);
label.top(btex VCC etex, arduino.VCC);
label.top(btex RST etex, arduino.RST);
label.top(btex GND etex, arduino.GND1);
label.top(btex DIN etex, arduino.B4);
label.top(btex CLK etex, arduino.E6);
label.top(btex CS etex, arduino.D7);
pickup A;
endgroup;

endfig;

end
