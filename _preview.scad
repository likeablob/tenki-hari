include <_tenki_hari_base.scad>

$fn = 80;

// front left
color("#EEE") th_parts_front(prev_side_joint = false);

// back left
color("#EEE") th_parts_back(next_side_joint = true);

// needle
color("#000") translate([ 10, 0, -1.5 ]) th_needle();

// front middle
translate([ -(TH_BODY_SIZE.x + 10), 0, 0 ]) color("#EEE") th_parts_front();

// front middle
translate([ -(TH_BODY_SIZE.x + 10) * 2, 0, 0 ]) color("#EEE") th_parts_front();

// front right
translate([ -(TH_BODY_SIZE.x + 10) * 3, 0, 0 ]) color("#EEE") color("#EEE")
    th_parts_front(rocker_switch = true, next_side_joint = false);

// back right
translate([ -(TH_BODY_SIZE.x + 10) * 3, 0, 0 ]) color("#EEE") color("#EEE")
    th_parts_back(next_side_joint = false);