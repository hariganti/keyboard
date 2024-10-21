// Fragment angle
$fa = $preview ? 0.5 : 0.1;
// Fragment size
$fs = $preview ? 0.25 : 0.05;

function sumv(vec, cur = 0, end = 0, sum = 0) =
  cur >= end ? sumv(vec, cur - 1, end, sum + vec[cur]) : sum;

module radius_rect(width, height, radius)
{
  offset_x = width  / 2 - radius;
  offset_y = height / 2 - radius;

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

module switchArray(layout, spacing, kerf)
{
  cutout = 14.00;
  for(i = [0:(len(layout) - 1)])
  {
    for(j = [0:(len(layout[i]) - 1)])
    {
      xloc = spacing * (sumv(layout[i], j) - layout[i][j] / 2);
      yloc = spacing * (len(layout) - 1 - i);
      translate([xloc, yloc])
        radius_rect(cutout - 2 * kerf, cutout - 2 * kerf, cutoutRadius);
    }
  }
}

module plate(width, height, recess, recessWidth, kerf)
{
  difference()
  {
    translate([width / 2, height / 2])
      radius_rect(width + 2 * kerf, height + 2 * kerf, margin / 2);

    translate([margin / 2, (margin + spacing) / 2])
      switchArray(layout, spacing, kerf);

    xnom          = width / 2;
    intervals     = 12; // Must be even
    recessSpacing = width / intervals;
    for(i = [-(intervals / 2 - 1):(intervals / 2 - 1)])
    {
      xloc = xnom + i * recessSpacing;
      translate([xloc, recess / 2 - kerf])
        square([recessWidth - 2 * kerf, recess - kerf], center = true);

      translate([xloc, height - (recess / 2 - kerf)])
        square([recessWidth - 2 * kerf, recess - kerf], center = true);
    }
  }
}

module switches()
{
  translate([margin / 2, (margin + spacing) / 2, 1.5 - 8.3])
    linear_extrude(height = 15)
      switchArray(layout, spacing, 0.5);
}

module stand(span, height, lift, thickness, recess, kerf)
{
  interference  = 0.1;
  legWidth      = 3 + kerf;
  points        =
  [
    [-(span - legWidth) / 2 + kerf,  -height    + kerf                    ],
    [-(span - legWidth) / 2 + kerf,  thickness  + kerf                    ],
    [-(span + legWidth) / 2 - kerf,  thickness  + kerf                    ],
    [-(span + legWidth) / 2 - kerf,  -(height   + legWidth + kerf)        ],
    [ (span + legWidth) / 2 + kerf,  -(height   + legWidth + lift + kerf) ],
    [ (span + legWidth) / 2 + kerf,  thickness  + kerf                    ],
    [ (span - legWidth) / 2 - kerf,  thickness  + kerf                    ],
    [ (span - legWidth) / 2 - kerf,  -height    + kerf                    ]
  ];

  difference()
  {
    union()
    {
      // Base
      polygon(points = points);

      // Clamp Caps
      for(i = [-1,1] / 2)
      {
        translate([i * span, thickness + kerf, 0])
          circle(d = legWidth + 2 * kerf);
      }
    }

    // Plate Attachment Recess
    translate([0, thickness / 2])
      square([span - 2 * (recess + interference + kerf), thickness - 2 * kerf + .1], center = true);
  }

  // Plate Support Legs
  for(i = [-2:2])
  {
    xloc = i * spacing;
    difference()
    {
      translate([xloc, -height / 2])
        square([legWidth + 2 * kerf, height + 2 * kerf], center = true);

      translate([xloc, 2 * kerf])
        rotate([0, 0, 45])
          square(25.4 * [0.05, 0.05], center = true);
    }
  }
}

module stiffener(width, height, kerf)
{
  radius_rect(width + 2 * kerf, height + 2 * kerf, 1);
}

/* Laser parameters */

kerf_3_0mm = 0.200;
kerf_1_5mm = 0.113;

/* Switch plate parameters */

margin        = 12.50;
recess        = 0.625;
spacing       = 19.05;
standoff      = 8.000;
legWidth      = 3.000;
thickness     = 1.500;
cutoutRadius  = 0.500;
layout        =
[
  [1.5,   1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    1.5 ],
  [1.75,  1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    2.25      ],
  [2,     1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    1   ],
  [1,     1,    1,    1.25,       2,          2,          2,    1.75, 1,    1,    1   ]
];

height  = margin + spacing * len(layout);
width   = margin + spacing * sumv(layout[0], len(layout[0]) - 1);

module render_3d()
{
  linear_extrude(height = thickness)
    plate(width, height, recess, 3.3, 0);

  switches();

  xnom          = width / 2;
  recessSpacing = width / 12;
  for(i = [-5:5])
  {
    translate([xnom + i * recessSpacing, height / 2, 0])
      rotate([90, 0, 90])
        linear_extrude(height = 3.175, center = true)
          stand(height, standoff, legWidth, thickness, recess, 0);
  }

  for(i = [-1, 1])
  {
    translate([width / 2, i * (2 * spacing + 3.175) + height / 2, -8 / 2])
      rotate([90, 0, 0])
        linear_extrude(height = 3.175, center = true)
          stiffener(width - 5, standoff, 0);
  }
}

render_3d();

// stiffener(width - 5, standoff - 0.8, kerf_3_0mm);

// stand(height, standoff, legWidth, thickness, recess, kerf_3_0mm);

// plate(width, height, recess, kerf_1_5mm);

// switchArray([[1]], 19.05, kerf_1_5mm);
