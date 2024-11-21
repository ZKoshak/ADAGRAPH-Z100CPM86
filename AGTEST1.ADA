WITH IO, UTIL, ADAGRAPH;
PACKAGE BODY AGTESTl IS
USE IO, UTIL, ADAGRAPH;
--
--THIS PROGRAM DRAWS A TEST PATTERN TO TEST COLOR SELECTION,
--CURSOR SETTING, CIRCLE DRAWING, LINE DRAWING, AREA FILLING,
--AND BOUNDARY FILLING
--
x_pos, y_pos : integer;
quit : character;
beqin
  CLS;
  x_pos := 320;
  y_pos := 108;
    color(5); --GREEN
    set_curs(300, 135);
    color(3); --BLUE
--DRAW A CIRCLE
    circle(300, 102, 142);
    color(6) ; --RED
-- DRAW A RECTANGLE
    draw_line(158, 31, 442, 31);
    draw_line(442, 31, 442, 173);
    draw_line(442, 173, 158, 173);
    draw_line(158, 173, 158, 31);
--DRAW A CIRCLE AND FILL IT
    circle(300, 102, 40);
    area_fill(300,102,3);
--DRAW AN IRREGULAR POLYGON AND FILL IT
    draw_line(20,20,8O,22);
    draw_line(80,22,84,50);
    draw_line(84,50,17,43);
    draw_line(17,43,20,20);
    boundarv_fill(50,35,6,6);
--DRAW A TRIANGLE AND FILL IT
    draw_line(50,100,80,130);
    draw_line(80,130,20,130);
    draw_line(50,100,20,130);
    area_fill(50,120,5);
    color(2); --MAGENTA
--DRAW A RECTANGLE
    draw_line(10, 10, 590, 10);
    draw_line(590, 10, 590, 205);
    draw_line(590, 205, 10, 205);
    draw_line(10, 205, 10, 10);
    color (5);
--DRAW A RECTANGLE WITH DIAGONAL LINES
    draw_line(200, 52, 400, 52);
    draw_line(400, 52, 400, 152);
    draw_line(400, 152, 200, 152);
    draw_line(200, 152, 200, 52);
    draw_line(200, 52, 400, 152);
    draw_line(200, 152, 400, 52);
    get(quit);
end AGTEST1;
