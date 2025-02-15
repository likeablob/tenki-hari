include <_tenki_hari_base.scad>

$fn = 80;
translate_lid_plane() rotate([ 180, 0, 0 ]) {
  color("#EEE") th_parts_back(next_side_joint = true);

  // AA battery
  % aa_battery();

  // SG90 servo
  % servo();
};