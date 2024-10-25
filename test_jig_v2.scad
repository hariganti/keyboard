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
  legWidth      = 3 + kerf; // *** THIS ALREADY ADDS IN THE KERF, SO REMOVE SUBSEQUENTLY! ***
  points        =
  [
    [-(span - legWidth) / 2 + kerf,  -height    + kerf                    ],
    [-(span - legWidth) / 2 + kerf,   thickness + kerf                    ],
    [-(span + legWidth) / 2 - kerf,   thickness + kerf                    ],
    [-(span + legWidth) / 2 - kerf,  -(height   + legWidth + kerf)        ],
    [ (span + legWidth) / 2 + kerf,  -(height   + legWidth + lift + kerf) ],
    [ (span + legWidth) / 2 + kerf,   thickness + kerf                    ],
    [ (span - legWidth) / 2 - kerf,   thickness + kerf                    ],
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

module bracket_stand(span, height, lift, thickness, recess, conLen, kerf)
{
  angle     = atan((lift - 1) / span);
  legWidth  = 3 + kerf;
  drop      = (conLen + legWidth) * tan(angle);
  nomSpan   = (span + legWidth) / 2 - 0.5 + kerf;
  points    =
  [
    [nomSpan,                             -(height + legWidth + lift + kerf)        ],
    [nomSpan + conLen + legWidth + kerf,  -(height + legWidth + lift + drop + kerf) ],
    [nomSpan + conLen + legWidth + kerf,   thickness + kerf                         ],
    [nomSpan + conLen - kerf,              thickness + kerf                         ],
    [nomSpan + conLen - kerf,              thickness + kerf - 10.1                  ],
    [nomSpan,                              thickness + kerf - 10.1                  ]
  ];

  difference()
  {
    union()
    {
      stand(span, height, lift, thickness, recess, kerf);
      polygon(points = points);
      translate([nomSpan + conLen + legWidth / 2, thickness + kerf])
        circle(d = legWidth + 2 * kerf);
    }

    translate([(span + lift + 35) / 2, 1.5 - 5])
      square([34.2, 10.2 - kerf], center = true);

    translate([(span + lift + 35) / 2, 1.5 - 10 - 2 / 2])
      square([3.2 - 2 * kerf, 2], center = true);
  }
}

module stiffener(width, height, kerf)
{
  radius_rect(width + 2 * kerf, height + 2 * kerf, 1);
}

module conHolder(span, count, conLen, kerf)
{
  start = count / 2;
  difference()
  {
    radius_rect(span * count + 10 + 2 * kerf, 10, 1);

    for(i = [-start:start])
    {
      translate([i * span, -(10 - 4) / 2])
        square([3.2 - 2 * kerf, 4 + 2 * kerf], center = true);
    }

    translate([0, 4])
      square([conLen + 2 * kerf, 6 + kerf], center = true);
  }
}

/* Laser parameters */

kerf_3_0mm = 0.200;
kerf_1_5mm = 0.113;

/* Switch plate parameters */

margin        = 12.50;
// recess        = 0.625;
recess = 1;
spacing       = 19.05;
standoff      = 8.000;
legWidth      = 3.000; // THIS IS NOT ACTUALLY DEFINING LEGWIDTH!!!
thickness     = 1.500;
cutoutRadius  = 0.500;
layout        =
[
  [1.5,   1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    1.5 ],
  [1.75,  1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    2.25      ],
  [2,     1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    1   ],
  [1,     1,    1,    1.25,       2,          2,          2,    1.75, 1,    1,    1   ]
];

height        = margin + spacing * len(layout);
width         = margin + spacing * sumv(layout[0], len(layout[0]) - 1);
xnom          = width / 2;
recessSpacing = width / 12;

module render_3d()
{
  linear_extrude(height = thickness)
    plate(width, height, recess, 3.3, 0);

  switches();

  for(i = [-2:5])
  {
    translate([xnom + i * recessSpacing, height / 2, 0])
      rotate([90, 0, 90])
        linear_extrude(height = 3.175, center = true)
          stand(height, standoff, legWidth, thickness, recess, 0);
  }

  for(i = [-5:-3])
  {
    translate([xnom + i * recessSpacing, height / 2, 0])
      rotate([90, 0, 90])
        linear_extrude(height = 3.175, center = true)
          bracket_stand(height, standoff, legWidth, thickness, recess, 35, 0);
  }

  for(i = [-1, 1])
  {
    translate([width / 2, i * (2 * spacing + 3.175) + height / 2, -8 / 2])
      rotate([90, 0, 0])
        linear_extrude(height = 3.175, center = true)
          stiffener(width - 5, standoff, 0);
  }

  translate([49.5, height + legWidth / 2 + 17.5, -9.5])
    rotate([90, 0, 0])
      linear_extrude(height = 3.175, center = true)
        conHolder(recessSpacing, 2, 45, 0);

  // Controller breadboard
  // translate([49.5, height + legWidth / 2 + 17.5, 1.5 - 5])
    // cube([45, 34.9, 10], center = true);
}

// render_3d();

// stiffener(width - 5, standoff, kerf_3_0mm);

// stand(height, standoff, legWidth, thickness, recess, kerf_3_0mm);

// bracket_stand(height, standoff, legWidth, thickness, recess, 35, kerf_3_0mm);

conHolder(recessSpacing, 2, 45, kerf_3_0mm);

// plate(width, height, recess, 3.3, kerf_1_5mm);

// switchArray([[1]], 19.05, kerf_1_5mm);
