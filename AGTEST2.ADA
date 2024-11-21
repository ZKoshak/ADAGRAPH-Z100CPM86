WITH IO, UTIL, ADAGRAPH;
PACKAGE BODY AGTEST2 IS
USE IO, UTIL, ADAGRAPH;
--
--THIS PROGRAM EXERCISES THE LIME DRAWING, CIRCLE,
--AND AREA FILLING PROCEDURES TO PRODUCE A PICTURE
--WITH COLORED CURVES AMD A COLOR WHEEL
--
i, X, y, y1, y2, pcol : integer;
quit : character;
begin
  CLS;
  y := 0;
  y1 := 0:
  color(6);
--LOOP TO DRAW CURVE 1
  for i in 0..63 loop
    x := i * 10;
    y2 := 189 - y1;
    draw_mline(x, y, 0, y2);
    y := y + 2;
    y1 := y1 + 3;
  end loop;
  y := 0;
  y1 := 0:
  color(l);
--LOOP TO DRAW CURVE 2
  for i in 0..63 loop
    x := 630 - (i * 10);
    y2 := 189 - y1;
    draw_mline(x, y, 630, y2);
    y := y + 2;
    y1 := y1 + 3;
  end loop;
--DRAW A COLOR WHEEL
  color(O); --WHITE
  circle(320, 150, 100);
  draw_line(320, 100, 320, 200);
  draw_line(220, 150, 420, 150);
  draw_line(249, 115, 391, 185);
  draw_line(391, 115, 249, 185);
  area_fill(355, 115, 0);   --COLOR 0 = WHITE
  area_fill(391, 140, 1);   --COLOR 1 = CYAN
  area_fill(391, 170, 2);   --COLOR 2 = MAGENTA
  area_fill(330, 185, 3);   --COLOR 3 = BLUE
  area_fill(310, 185, 4);   --COLOR 4 = YELLOW
  area_fill(249, 160, 5);   --COLOR 5 = GREEN
  area_fill(249, 130, 6);   --COLOR 6 = RED
  get (quit);
end AGTEST2;
