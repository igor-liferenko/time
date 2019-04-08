%outputtemplate:="%j.eps"; prologues:=3;

input boxes;

verbatimtex
\font\tenss=cmss10 \tenss
etex

beginfig(1);
u:=2cm;
boxit.b1(btex 1 etex);
b1.e-b1.w=right*1u;
b1.n-b1.s=up*1u;
drawboxes(b1); draw pic(b1) shifted (down*.2u);
drawarrow b1.e+up*.3u .. b1.w+up*.3u;
boxit.b2(btex 2 etex);
b2.w=b1.w+right*1u;
b2.e-b2.w=right*1u;
b2.n-b2.s=up*1u;
drawboxes(b2); draw pic(b2) shifted (down*.2u);
drawarrow b2.e+up*.3u .. b2.w+up*.3u;
boxit.b3(btex 3 etex);
b3.w=b2.w+right*1u;
b3.e-b3.w=right*1u;
b3.n-b3.s=up*1u;
drawboxes(b3); draw pic(b3) shifted (down*.2u);
drawarrow b3.e+up*.3u .. b3.w+up*.3u;
boxit.b4(btex 4 etex);
b4.w=b3.w+right*1u;
b4.e-b4.w=right*1u;
b4.n-b4.s=up*1u;
drawboxes(b4); draw pic(b4) shifted (down*.2u);
drawarrow b4.e+up*.3u .. b4.w+up*.3u;
draw b4.e+up*.2u .. b4.e+right*.2u+up*.2u;
draw b4.e+up*.1u .. b4.e+right*.2u+up*.1u;
draw b4.e .. b4.e+right*.2u;
draw b4.e+down*.1u .. b4.e+right*.2u+down*.1u;
draw b4.e+down*.2u .. b4.e+right*.2u+down*.2u;

endfig;

end
