/**
 * Keyboard Test Jig
 */

// Fragment angle
$fa = $preview ? 0.5 : 0.25;
// Fragment size
$fs = $preview ? 0.25 : 0.1;

kerf      = 0.18;   // mm
numRows   = 4;
numCols   = 15;
subdiv    = 4;
numLayers = 4;
keyPitch  = 19.05;  // mm
layerZ    = 1.5;    // mm

centerPin     = 5.00; // Switch pin clearance diameter (mm)
centerHeight  = (numLayers - 1) * layerZ;

wireDia   = 0.50; // Bare wire diameter(mm)
diodeDia  = 1.80; // Diode body diameter (mm)
insulDia  = 1.30; // Wire insulation diameter (mm)

module radius_template(height, radius)
{
  cylinder(h = height, r = radius, center = false);
}

module radius_prism_template(width, height, depth, radius)
{
  width   = width   - 2 * kerf;
  height  = height  - 2 * kerf;
  radius  = radius  - kerf;
  
  offsetX = width   / 2 - radius; // X center-point offset
  offsetY = height  / 2 - radius; // Y center-point offset
  union()
  {
    translate([offsetX, offsetY, -depth])
      radius_template(depth, radius);

    translate([-offsetX, offsetY, -depth])
      radius_template(depth, radius);

    translate([offsetX, -offsetY, -depth])
      radius_template(depth, radius);

    translate([-offsetX, -offsetY, -depth])
      radius_template(depth, radius);

    translate([0, 0, -depth / 2])
    {
      cube(size = [2 * offsetX, height,       depth], center = true);
      cube(size = [width,       2 * offsetY,  depth], center = true);
    }
  }
}

module key_switch_template(centerPin, centerHeight)
{
// Set variables
  pinWidth      = 0.80;       // mm
  pinHeight     = 0.20;       // mm
  clearance     = 0.05;       // mm
  radius        = 0.25;       // (mm)
  pin1X         = 0;          // mm - Low Profile
  pin1Y         = -5.90;      // mm - Low Profile
  pin2X         = -5.00;      // mm - Low Profile
  pin2Y         = -3.80;      // mm - Low Profile
  pin3X         = -3.80;      // mm - Standard
  pin3Y         = 2.54;       // mm - Standard
  pin4X         = 2.54;       // mm - Standard
  pin4Y         = 5.08;       // mm - Standard
  footX         = 10.16 / 2;  // mm
  addtlBusDist  = 12.5;       // Additional bus length (mm)
  fullX     = pinWidth  + 2 * clearance;
  fullY     = pinHeight + 2 * wireDia;
  fullZ     = numLayers * layerZ;

  // Make center pin
  translate([0, 0, -centerHeight])
    cylinder(h = centerHeight, d = (centerPin - 2 * kerf), center = false);

  // Row Union - Low Profile
  union()
  {
    // Make pin 1
    translate([pin1X, pin1Y, 0])
      radius_prism_template(fullX, fullY, fullZ, radius);

    // Make row bus (sized for diodes)
    translate([0, pin1Y, 0])
      radius_prism_template(keyPitch + addtlBusDist, diodeDia, layerZ, radius);
  }

  // Row Union - Standard
  union()
  {
    // Make pin 3
    translate([pin3X, pin3Y, 0])
      radius_prism_template(fullX, fullY, fullZ, radius);

    // Make row bus (sized for diodes)
    translate([0, pin3Y, 0])
      radius_prism_template(keyPitch + addtlBusDist, diodeDia, layerZ, radius);
  }

  // Col Union - Low Profile
  union()
  {
    // Make pin 2
    translate([pin2X, pin2Y, 0])
      radius_prism_template(fullX, fullY, fullZ, radius);

    // Make col bus (sized for wire)
    translate([pin2X, 0, -1 * (numLayers - 1) * layerZ])
      radius_prism_template(insulDia, keyPitch + addtlBusDist, layerZ, radius);

    // Make col bus jog (sized for wire)
    translate([0, -pin1Y, -2 * layerZ])
      radius_prism_template(keyPitch + addtlBusDist, insulDia, layerZ, radius);
  }

  // Col Union - Standard
  union()
  {
    // Make pin 4
    translate([pin4X, pin4Y, 0])
      radius_prism_template(fullX, fullY, fullZ, radius);

    // Make col bus (sized for wire)
    translate([pin4X, 0, -1 * (numLayers - 1) * layerZ])
      radius_prism_template(insulDia, keyPitch + addtlBusDist, layerZ, radius);

    // Make col bus jog (sized for wire)
    translate([0, -pin4Y, -2 * layerZ])
      radius_prism_template(keyPitch + addtlBusDist, insulDia, layerZ, radius);
  }

  // Make the feet
  union()
  {
    translate([footX, 0, -3 * layerZ])
      cylinder(h = 3 * layerZ, d = (1.70 - 2 * kerf), center = false);

    translate([-footX, 0, -3 * layerZ])
      cylinder(h = 3 * layerZ, d = (1.70 - 2 * kerf), center = false);
  }
}

module center_pin_radius(centerPin, spacing, height, radius)
{
  difference()
  {
    b = sqrt((centerPin / 2 + radius) ^ 2 - (spacing / 2) ^ 2);
    h = b * centerPin / (centerPin + 2 * radius);

    difference()
    {
      translate([spacing / 2, 0, -height / 2])
        cube(size = [spacing, 2 * h, height], center = true);

      translate([spacing / 2, b, -height / 2])
        cylinder(h = height + .1, r = radius, center = true);

      translate([spacing / 2, -b, -height / 2])
        cylinder(h = height + .1, r = radius, center = true);
    }
  }
}

module interconnect_grid(numRows, numCols, keyPitch, subdiv)
{
  numPos  = subdiv * (numCols - 1);
  spacing = keyPitch / subdiv;

  union()
  {
    for(j = [0:(numRows - 1)])
    {
      for(i = [0:numPos])
      {
        translate([i * spacing, j * keyPitch, 0])
          key_switch_template(centerPin, centerHeight);

        if(i != numPos)
          translate([i * spacing, j * keyPitch, 0])
            center_pin_radius(centerPin, spacing, centerHeight, 1);
      }
    }
  }
}

module layers(width, height, depth, num)
{
  translate([width / 2, height / 2, -0.025 - num * depth])
  {
    radius_prism_template(width, height, depth - .05, 5);
  }
}

module fastening()
{
  width   = keyPitch * numCols + 3.75;
  height  = keyPitch * numRows + 3.75;
  depth   = numLayers * layerZ;
  holes   =
  [
  //      X             Y
    [width / 2,   -1.5        ],
    [-width / 2,  -1.5        ],
    [-1.25,       height / 2  ],
    [-1.25,       -height / 2 ]
  ];

  union()
  {
    for(i = holes)
    {
      translate([i[0], i[1], -depth])
        cylinder(h = depth, d = 4.3053, center = false);
    }
  }
}

module generate_model(start, stop, layerBounds)
{
  difference()
  {
    union()
    {
      for(i = [start:stop])
      {
        xBound  = layerBounds[i][0];
        yBound  = layerBounds[i][1];
        width   = keyPitch * numCols + 2 * xBound;
        height  = keyPitch * numRows + 2 * yBound;
        translate([-keyPitch / 2 - xBound, -keyPitch / 2 - yBound, 0])
          layers(width, height, layerZ, i);
      }
    }
      interconnect_grid(numRows, numCols, keyPitch, subdiv);
      fastening();
  }
}

/**
 * MAIN
 */

layers =
[
//  X       Y
  [7.5, 7.5],
  [5,   7.5],
  [7.5,   5],
  [7.5, 7.5]
];

// layer = 3;
// projection(cut = false) generate_model(layer, layer, layers);

/**
 * TEST
 */

interconnect_grid(numRows, numCols, keyPitch, subdiv);
generate_model(0, 3, layers);
