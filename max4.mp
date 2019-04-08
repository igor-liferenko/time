outputtemplate:="%j.eps"; prologues:=3;

input boxes;

beginfig(1);
boxit.b1(btex 1 etex);
b1.e-b1.w=right*1cm;
b1.n-b1.s=up*1cm;
drawboxes(b1); draw pic(b1) shifted (up*2mm);
drawarrow b1.e+down*2mm .. b1.w+down*2mm;
boxit.b2(btex 2 etex);
b2.w=b1.w+right*1cm;
b2.e-b2.w=right*1cm;
b2.n-b2.s=up*1cm;
drawboxes(b2); draw pic(b2) shifted (up*2mm);
drawarrow b2.e+down*2mm .. b2.w+down*2mm;
boxit.b3(btex 3 etex);
b3.w=b2.w+right*1cm;
b3.e-b3.w=right*1cm;
b3.n-b3.s=up*1cm;
drawboxes(b3); draw pic(b3) shifted (up*2mm);
drawarrow b3.e+down*2mm .. b3.w+down*2mm;
boxit.b4(btex 4 etex);
b4.w=b3.w+right*1cm;
b4.e-b4.w=right*1cm;
b4.n-b4.s=up*1cm;
drawboxes(b4); draw pic(b4) shifted (up*2mm);
drawarrow b4.e+down*2mm .. b4.w+down*2mm;
endfig;

end
