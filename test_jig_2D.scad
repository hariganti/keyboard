// Fragment angle
$fa = $preview ? 0.5 : 0.25;
// Fragment size
$fs = $preview ? 0.25 : 0.1;

module radius_rect(width, height, radius)
{
  offset_x = width  / 2 - radius;
  offset_y = height / 2 - radius;
  union()
  {
    square([width,        2 * offset_y],  center = true);
    square([2 * offset_x, height],        center = true);
    
    translate([offset_x, offset_y])
      circle(r = radius);
    
    translate([-offset_x, offset_y])
      circle(r = radius);
    
    translate([-offset_x, -offset_y])
      circle(r = radius);
    
    translate([offset_x, -offset_y])
      circle(r = radius);
  }
}

module switch(kerf)
{
  dia       = 5;      // mm
  pin1X     = 0;      // mm
  pin1Y     = -5.90;  // mm
  pin2X     = -5.00;  // mm
  pin2Y     = -3.80;  // mm
  pinWidth  = 1.2;    // mm
  pinHeight = 1.0;    // mm
  pinRadius = 0.5;    // mm
  
  union()
  {
    circle(d = dia - 2 * kerf);
      
    translate([pin1X, pin1Y, 0])
      radius_rect(pinWidth, pinHeight, pinRadius);
      
    translate([pin2X, pin2Y, 0])
      radius_rect(pinWidth, pinHeight, pinRadius);
  }
}

module switch_grid_test(pitch, pos_x, pos_y, subdiv_x, subdiv_y, kerf)
{
  for(i = [0:pos_x * subdiv_x])
  {
    for(j = [0:pos_y * subdiv_y])
    {
      translate([i * pitch / subdiv_x, j * pitch / subdiv_y, 0])
        switch(kerf);
    }
  }
}

kerf    = 0.20;   // mm - Single-sided
// kerf    = 0;
rows    = 4;
cols    = 15;
rowSub  = 1;
colSub  = 2;
pitch   = 19.05;
margin  = 12.5;

difference()
{
  cols = cols - 1; // The difference between 0- and 1-indexing
  rows = rows - 1;
  width   = pitch * cols + 2 * margin;
  height  = pitch * rows + 2 * margin;
  
  echo(width, height);
  
   translate([width / 2, height / 2])
    radius_rect(width - 0.75, height - 0.75, 6.25);
  
  translate([margin, margin])
    switch_grid_test(pitch, cols, rows, colSub, rowSub, kerf);
}
