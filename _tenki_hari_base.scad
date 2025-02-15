include <MCAD/servos.scad>
include <scad-utils/morphology.scad>

$fn = 60;

TH_BODY_SIZE = [ 42, 66, 31 ];
TH_BODY_R = 2;
TH_FACE_THICKNESS = 0.6;
TH_SHELL_THICKNESS = 1.6;

TH_BACKPANEL_THICKNESS = 1.2;

TH_JOINT_SIZE = [ 10, 25, 10 ];

aa_battery_size = [ 14, 50 ];
holder_base_size = [ aa_battery_size.x + 4, 10, aa_battery_size.x ];
holder_base_top = 7;
holder_base_y_offset = 2.5;

*translate([ -4, 0, 14 / 2 + 4 ]) rotate([ 90, 0, 0 ])
    cylinder(d = 14, h = 51, center = true);

module th_base_shape() {
  rounding(r = TH_BODY_R)
      square(size = [ TH_BODY_SIZE.x, TH_BODY_SIZE.y ], center = true);
}

module th_face() {
  difference() {
    th_base_shape();

    // hole for the clock hand
    translate([ 10, 0, 0 ]) circle(d = 5.2);

    // icons
    icons_r = TH_BODY_SIZE.x / 2 + 1;
    icons_deg = [ 60, 0, -60 ];
    icons_files = [ "brightness.svg", "cloud-fill.svg", "umbrella-fill.svg" ];

    *for (i = [0:2]) {
      translate([
        TH_BODY_SIZE.x / 4 - cos(icons_deg[i]) * icons_r,
        sin(icons_deg[i]) * icons_r, 0
      ]) resize([ 18, 0, 0 ], auto = true)
          import(file = icons_files[i], center = true, dpi = 96);
    }

    gauge_arc_r = 20;

    // gauge
    translate([ 10, 0, 0 ]) {
      // arc
      for (i = [-60:60]) {
        rotate([ 0, 0, i ]) translate([ -gauge_arc_r, 0, 0 ]) circle(d = 1.2);
      }

      // ticks
      *for (i = [-60:30:60]) {
        hull() {
          rotate([ 0, 0, i ]) translate([ -gauge_arc_r, 0, 0 ]) circle(d = 2);
          // translate([-gauge_arc_r, 0, 0]){
          //   square(size=[0.5, 2], center=true);
          //   // circle(d=1);

          //   translate([-1, 0, 0])
          //   // circle(d=1);
          //   square(size=[0.5, 2], center=true);
          // }
        }
      }

      // dot
      rotate([ 0, 0, 90 ]) translate([ -gauge_arc_r, 0, 0 ]) circle(d = 2);
    }
  }
}

module th_shell_base() {
  color("#EEE") linear_extrude(height = TH_BODY_SIZE.z, center = false,
                               convexity = 10, twist = 0)
      shell(d = -TH_SHELL_THICKNESS, center = false) th_base_shape();
}

module th_shell(top = false, gap = 0.5) {
  x_pos = top ? (TH_BODY_SIZE.x * 1.1 / 2) - TH_BODY_SIZE.x / 2 + TH_BODY_R +
                    gap / 2
              : (-TH_BODY_SIZE.x * 1.1 / 2) - TH_BODY_SIZE.x / 2 + TH_BODY_R -
                    gap / 2;
  z_pos = top ? 0 : TH_FACE_THICKNESS + gap;

  intersection() {
    *translate([ x_pos, 0, TH_BODY_SIZE.z * 1.1 / 2 + z_pos ])
        cube(size = TH_BODY_SIZE * 1.1, center = true);

    th_shell_base();
  }
}

module th_parts_front(rocker_switch = false,
                      next_side_joint = true,
                      prev_side_joint = true) {
  linear_extrude(height = TH_FACE_THICKNESS, center = false, convexity = 10,
                 twist = 0) th_face();

  difference() {
    th_shell(top = true);

    // for lid
    translate([ 0, 0, TH_BODY_SIZE.z - TH_BACKPANEL_THICKNESS - 0.4 ])
        linear_extrude(height = TH_BACKPANEL_THICKNESS * 2, center = !true,
                       convexity = 10, twist = 0)
            inset(d = TH_SHELL_THICKNESS - 0.6) th_base_shape();

    if (next_side_joint) {
      // for lid joint
      translate([
        -TH_BODY_SIZE.x / 2 + TH_SHELL_THICKNESS / 2, 0,
        TH_BODY_SIZE.z - TH_JOINT_SIZE.z - 0.5
      ]) linear_extrude(height = TH_JOINT_SIZE.z + 0.5, center = !true,
                        convexity = 10, twist = 0)
          square(size = [ TH_SHELL_THICKNESS * 2, TH_JOINT_SIZE.y + 1.5 ],
                 center = true);
    }

    if (prev_side_joint) {
      // screw holes for left joint
      translate([ TH_BODY_SIZE.x / 2, 0, -TH_JOINT_SIZE.z ])
          translate_lid_plane() mirror_y()
              translate([ 0, TH_JOINT_SIZE.y / 2 - 5, TH_JOINT_SIZE.z / 3 ])
                  rotate([ 0, 90, 0 ]) cylinder(d = 1.6, h = 10, center = true);

      // cable holes for joint
      translate(
          [ TH_BODY_SIZE.x / 2 - TH_JOINT_SIZE.x / 2, 0, -TH_JOINT_SIZE.z ])
          translate_lid_plane() hull() {
        mirror_y() translate([ 0, -2, TH_JOINT_SIZE.z / 2 ])
            rotate([ 0, 90, 0 ])
                cylinder(d = 5, h = TH_JOINT_SIZE.x * 2, center = true);

        mirror_y() translate([ 0, -2, TH_JOINT_SIZE.z ]) rotate([ 0, 90, 0 ])
            cylinder(d = 5, h = TH_JOINT_SIZE.x * 2, center = true);
      }
    }

    if (rocker_switch) {
      // hole for rocker switch
      translate([
        -TH_BODY_SIZE.x / 2, -TH_BODY_SIZE.y / 2 + 14.1 / 2 + 6,
        TH_BODY_SIZE.z / 2 - 6
      ]) cube(size = [ 10, 14.1, 9 ], center = true);
    }
  }

  // screw bases for lid
  pos_lid_screws() translate([ 0, 0, -TH_BACKPANEL_THICKNESS - 0.4 ])
      difference() {
    hull() {
      screw_base_size = [ 5, 7, 10 ];
      linear_extrude(height = 0.01, center = true, convexity = 10, twist = 0)
          square([ screw_base_size.x, screw_base_size.y ], center = true);

      translate([ screw_base_size.x / 2, 0, -screw_base_size.z ])
          linear_extrude(height = 0.01, center = true, convexity = 10,
                         twist = 0)
              square([ 0.01, screw_base_size.y ], center = true);
    }

    // screw holes
    cylinder(d = 1.8, h = 10, center = true);
  }
}

module translate_lid_plane() {
  translate([ 0, 0, TH_BODY_SIZE.z ]) children();
}

SERVO_HOLDER_BASE_SIZE = [ 11.5, 4.5, TH_BODY_SIZE.z - 13 ];
SERVO_SCREW_HOLE_TO_HOLE = 28;

module servo_holder_base() {
  difference() {
    mirror_y() translate([
      0, SERVO_SCREW_HOLE_TO_HOLE / 2 + 0.5, -SERVO_HOLDER_BASE_SIZE.z / 2
    ]) difference() {
      cube(SERVO_HOLDER_BASE_SIZE, center = true);

      // space for cables
      hull() {
        translate([ 0, 0, SERVO_HOLDER_BASE_SIZE.z ]) rotate([ 90, 0, 0 ])
            cylinder(d = 4.5, h = SERVO_HOLDER_BASE_SIZE.y + 1, center = true);

        rotate([ 90, 0, 0 ])
            cylinder(d = 4.5, h = SERVO_HOLDER_BASE_SIZE.y + 1, center = true);
      }
    }

    // screw holes
    mirror_y() translate(
        [ 0, SERVO_SCREW_HOLE_TO_HOLE / 2, -SERVO_HOLDER_BASE_SIZE.z / 2 ])
        cylinder(d = 1.8, h = SERVO_HOLDER_BASE_SIZE.z, center = true);
  }
}

module th_parts_back(next_side_joint = true) {
  if (next_side_joint) {
    // joint
    translate(
        [ -TH_BODY_SIZE.x / 2 - TH_JOINT_SIZE.x / 2, 0, -TH_JOINT_SIZE.z ])
        translate_lid_plane() difference() {
      union() {
        linear_extrude(height = TH_JOINT_SIZE.z, center = !true, convexity = 10,
                       twist = 0) fillet(r = 6) union() {
          mirror_x() translate([ TH_JOINT_SIZE.x / 2, 0, 0 ])
              square(size = [ 0.01, TH_JOINT_SIZE.y ], center = true);
        }

        // lid joint
        translate([ TH_JOINT_SIZE.z / 2 + TH_SHELL_THICKNESS / 2, 0, 0 ])
            linear_extrude(height = TH_JOINT_SIZE.z, center = !true,
                           convexity = 10, twist = 0)
                square(size = [ TH_SHELL_THICKNESS, TH_JOINT_SIZE.y ],
                       center = true);
      }

      // screw holes
      mirror_y() translate([
        -TH_JOINT_SIZE.x / 2, TH_JOINT_SIZE.y / 2 - 5, TH_JOINT_SIZE.z / 3
      ]) rotate([ 0, 90, 0 ]) cylinder(d = 1.6, h = 10, center = true);

      // cable holes
      hull() {
        mirror_y() translate([ 0, -2, TH_JOINT_SIZE.z / 2 ])
            rotate([ 0, 90, 0 ])
                cylinder(d = 5, h = TH_JOINT_SIZE.x * 2, center = true);
      }
    }
  }

  // lid
  difference() {
    translate([ 0, 0, -TH_BACKPANEL_THICKNESS ]) translate_lid_plane()
        linear_extrude(height = TH_BACKPANEL_THICKNESS, center = !true,
                       convexity = 10, twist = 0)
            inset(d = TH_SHELL_THICKNESS - 0.4) th_base_shape();

    // screw holes
    pos_lid_screws() cylinder(d = 2, h = 10, center = true);

    // band holes
    for (i = [ 0, TH_BODY_SIZE.y / 2.5 ]) {
      translate([ 0, (TH_BODY_SIZE.y / 4) - i, 0 ]) translate_lid_plane()
          linear_extrude(height = TH_BACKPANEL_THICKNESS * 2, center = true,
                         convexity = 10, twist = 0) union() {
        BAND_HOLE_SIZE = [ 23, 3, 1.5 ];

        mirror_x() translate([
          BAND_HOLE_SIZE.x / 2 - BAND_HOLE_SIZE[2] * 2 / 2,
          BAND_HOLE_SIZE.y / 2, 0
        ]) square(size = [ BAND_HOLE_SIZE[2] * 2, BAND_HOLE_SIZE.y ],
                  center = true);

        square(size = [ BAND_HOLE_SIZE.x, BAND_HOLE_SIZE[2] ], center = true);
      }
    }

    // space for battery
    translate([ -14 / 2, 0, -TH_BACKPANEL_THICKNESS - 1 ]) translate_lid_plane()
        linear_extrude(height = aa_battery_size.x / 2, center = !true,
                       convexity = 10, twist = 0)
            square(size =
                       [
                         aa_battery_size.x + 1.5, aa_battery_size.y +
                         holder_base_y_offset
                       ],
                   center = true);
  }

  // servo holder
  translate_lid_plane() {
    translate([ 10, -5.35, 0 ]) servo_holder_base();
  }

  // battery holder
  translate([ -14 / 2, 0, -TH_BACKPANEL_THICKNESS ]) translate_lid_plane()
      rotate([ 180, 0, 0 ]) aa_battery_holder();
}

module pos_lid_screws() {
  translate_lid_plane() mirror_x() mirror_y()
      translate([ TH_BODY_SIZE.x / 2 - 3, 17, 0 ]) children();
}

module th_needle() {
  linear_extrude(height = 1, center = true, convexity = 10, twist = 0)
      difference() {  // base
    union() {         // hand
      hull() {
        translate([ -25, 0, 0 ]) circle(d = 1.2);
        circle(d = 6);
      }

      // axis
      circle(d = 4.5);
    }

    // screw hole
    circle(d = 2.5);
  };
}

// *color("#444") translate([ 10, 0, -1.5 ]) th_needle();

// color("#EEE") th_parts_front();

// color("#EEE") th_parts_front(rocker_switch=true, next_side_joint=false);

// *
// color("#444") th_parts_back();

// color("#444") th_parts_back(next_side_joint = false);

// % color("#EEE") translate([ -(TH_BODY_SIZE.x + 10), 0, 0 ])
//         linear_extrude(height = TH_FACE_THICKNESS,
//                        center = false,
//                        convexity = 10,
//                        twist = 0) th_face();

module aa_battery_holder() {
  difference() {
    // holder bases
    mirror_y()
        translate([ 0, -aa_battery_size.y / 2 - holder_base_size.y / 2 + 5, 0 ])
            hull() {
      translate([
        0, holder_base_size.y / 2 - holder_base_top / 2, holder_base_size.z
      ]) linear_extrude(height = 0.01, center = true, convexity = 10, twist = 0)
          square(size = [ holder_base_size.x, holder_base_top ], center = true);

      linear_extrude(height = 0.01, center = true, convexity = 10, twist = 0)
          rounding(r = 1) square(
              size = [ holder_base_size.x, holder_base_size.y ], center = true);
    }

    // space for battery
    translate([ 0, 0, -0.01 ]) linear_extrude(
        height = aa_battery_size.x / 2, center = !true, convexity = 10,
        twist = 0) square(size =
                              [
                                aa_battery_size.x + 1.5, aa_battery_size.y +
                                holder_base_y_offset
                              ],
                          center = true);

    translate([ 0, 0, (aa_battery_size.x + 1.5) / 2 ]) rotate([ 90, 0, 0 ])
        cylinder(d = aa_battery_size.x + 1.5,
                 h = aa_battery_size.y + holder_base_y_offset, center = true);

    // space for battery contacts
    mirror_y()
        translate([ 0, -aa_battery_size.y / 2 - holder_base_y_offset / 2, 0 ])
            linear_extrude(height = aa_battery_size.x + 10, center = !true,
                           convexity = 10, twist = 0) union() {
      translate([ 0, -1 / 2, 0 ]) square(size = [ 9, 1 ], center = true);

      translate([ 0, -1 / 2 - 1, 0 ]) square(size = [ 12.5, 1 ], center = true);
    }
  }
}

module aa_battery() {
  translate([ -14 / 2, 0, -14 / 2 - TH_BACKPANEL_THICKNESS ])
      translate_lid_plane() rotate([ 90, 0, 0 ])
          cylinder(d = 14, h = 50, center = true);
}

module servo() {
  translate([ 10, 0, 29.8 - 1 ]) rotate([ 180, 0, -90 ])
      towerprosg90(screws = 1, axle_length = 0, cables = 1);
}