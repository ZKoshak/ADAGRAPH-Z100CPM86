WITH IO, UTIL, ADAGRAPH;
PACKAGE BODY AGTEST3 IS
USE IO, UTIL, ADAGRAPH;
--
--THIS PROGRAM IS USED TO TEST SETTING AND RESETTING
--OF A GRAPHICS CURSOR. THE PROGRAM REOUESTS CURSOR
--POSITION INPUTS, ERASES THE PREVIOUS CURSOR, AND
--DRAWS A CURSOR AT THE INPUT (X,Y) COORDINATE
--
i : integer;
x_pos, y_pos, x_old, y_old : integer;
begin
  CLS;
  x_old := 0;   --INITIALIZE X & Y
  y_old := 0;
  for i in 1..50 loop
    put("ENTER X POSITION ");
    get(x_pos);
    put("ENTER Y POSITION ");
    get(y_pos);
    color(5);   --GREEN
    reset_curs(x_old, y_old);
    set_curs(x_pos, y_pos);
    x_old := x_pos;
    y_old := y_pos - 18;
  end loop;
end AGTEST3;
