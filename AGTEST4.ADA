WITH IO, UTIL, ADAGRAPH;
PACKAGE BODY AGTEST4 IS
USE IO, UTIL, ADAGRAPH;
--THIS PROGRAM IS USED TO DISPLAY A CIRCLE OF THE APPROXIMATE
--MAXIMUM AREA THAT CAN BE FILLED BY A SINGLE CALL TO ONE OF
--THE FILL ROUTINES. IT THEN DEMONSTRATES FILLING AND
--DRAWING OF POLYGONS USING ONLY THE SET_PIXEL AND RESET_PIXEL
--PROCEDURES.
x, y :INTEGER;
quit : character;
begin
  CLS;
--SELECT COLOR
      color(O);   --WHITE
--DRAW A CIRCLE
      circle(300, 102, 115);
--FILL THE CIRCLE WITH RED
      boundary_fill(300, 102, 6, 0);
color (1);    --CYAN
--DRAW A RECTANGLE USING SET PIXEL
for x in 250..350 loop
  set_pixel(x, 77);
  set_pixel(x, 127);
end loop;
for y in 77..127 loop
  set_pixel(250, y);
  set_pixel(350, y);
end loop;
--FILL THE RECTANGLE
area_fill(300, 102, 5);   --COLOR 5 = GREEN
--ERASE A RECTANGLE USING RESET PIXEL
for x in 280..320 loop
  for y in 92..112 loop
    reset_pixel(x, y);
  end loop;
end loop;
area_fill(375, 102, 2);
color (6);
      qet(quit);
end AGTEST4;
