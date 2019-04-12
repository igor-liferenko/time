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
drawboxes(arduino); draw pic(arduino) shifted (up*.2u);

% pins
pair arduino[],arduino.B[],arduino.E[],arduino.D[],arduino.GND,arduino.VCC,arduino.RST;
xpart(arduino.B6)=xpart(arduino.w)+.2u; ypart(arduino.B6)=ypart(arduino.s);
xpart(arduino.B2)=xpart(arduino.B6)+.45u; ypart(arduino.B2)=ypart(arduino.s);
xpart(arduino.14)=xpart(arduino.B2)+.45u; ypart(arduino.14)=ypart(arduino.s);
xpart(arduino.B1)=xpart(arduino.14)+.45u; ypart(arduino.B1)=ypart(arduino.s);
xpart(arduino.VCC)=xpart(arduino.RST)-.48u; ypart(arduino.VCC)=ypart(arduino.s);
xpart(arduino.RST)=xpart(arduino.GND)-.48u; ypart(arduino.RST)=ypart(arduino.s);
xpart(arduino.GND)=xpart(arduino.e)-.6u; ypart(arduino.GND)=ypart(arduino.s);
% draw
begingroup;
interim rbox_radius:=1bp;
save A; pen A; A:=currentpen;
pickup pencircle scaled .1pt;
label.top(btex 16 etex, arduino.B2);
rboxit.arduino.B2_box(btex B2 etex);
arduino.B2_box.c=arduino.B2+up*.4u;
arduino.B2_box.ne=arduino.B2_box.sw+right*.3u+up*.2u;
drawboxed(arduino.B2_box);
label.top(btex 10 etex, arduino.B6);
rboxit.arduino.B6_box(btex B6 etex);
arduino.B6_box.c=arduino.B6+up*.4u;
arduino.B6_box.ne=arduino.B6_box.sw+right*.3u+up*.2u;
drawboxed(arduino.B6_box);
label.top(btex 15 etex, arduino.B1);
rboxit.arduino.B1_box(btex B1 etex);
arduino.B1_box.c=arduino.B1+up*.4u;
arduino.B1_box.ne=arduino.B1_box.sw+right*.3u+up*.2u;
drawboxed(arduino.B1_box);
label.top(btex 14 etex, arduino.14);
label.top(btex VCC etex, arduino.VCC);
label.top(btex RST etex, arduino.RST);
label.top(btex GND etex, arduino.GND);
label.bot(btex DIN etex, arduino.B2+down*.05u);
label.bot(btex CS etex, arduino.B6+down*.05u);
label.bot(btex CLK etex, arduino.B1+down*.05u);
pickup A;
endgroup;

endfig;

beginfig(2);
u:=2cm;
boxit.b1(btex 1 etex);
b1.e-b1.w=right*1u;
b1.n-b1.s=up*1u;
drawboxes(b1); draw pic(b1) shifted (down*.2u);
drawarrow b1.e+up*.3u+left*.05u .. b1.w+up*.3u+right*.05u;
boxit.b2(btex 2 etex);
b2.w=b1.w+right*1u;
b2.e-b2.w=right*1u;
b2.n-b2.s=up*1u;
drawboxes(b2); draw pic(b2) shifted (down*.2u);
drawarrow b2.e+up*.3u+left*.05u .. b2.w+up*.3u+right*.05u;
boxit.b3(btex 3 etex);
b3.w=b2.w+right*1u;
b3.e-b3.w=right*1u;
b3.n-b3.s=up*1u;
drawboxes(b3); draw pic(b3) shifted (down*.2u);
drawarrow b3.e+up*.3u+left*.05u .. b3.w+up*.3u+right*.05u;
boxit.b4(btex 4 etex);
b4.w=b3.w+right*1u;
b4.e-b4.w=right*1u;
b4.n-b4.s=up*1u;
drawboxes(b4); draw pic(b4) shifted (down*.2u);
drawarrow b4.e+up*.3u+left*.05u .. b4.w+up*.3u+right*.05u;
draw b4.e+up*.2u .. b4.e+right*.2u+up*.2u;
draw b4.e+up*.1u .. b4.e+right*.2u+up*.1u;
draw b4.e .. b4.e+right*.2u;
draw b4.e+down*.1u .. b4.e+right*.2u+down*.1u;
draw b4.e+down*.2u .. b4.e+right*.2u+down*.2u;

endfig;

end
