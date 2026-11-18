#!/bin/bash
G=/tmp/godot/Godot_v4.7-stable_linux.x86_64
OUT=$1
cd /home/user/thekicker
run() { timeout 25 xvfb-run -a -s "-screen 0 1280x1400x24" $G --path . --resolution 720x1280 res://tests_tmp/style_preview.tscn -- "$@" 2>&1 | grep -E "SCRIPT ERROR|Parse Error|ERROR: res|at: " | head -20; }
for s in A B C; do for sc in main hub; do run style=$s screen=$sc out=$OUT/${s}_$sc.png; done; done
run style=C screen=hub light=1 out=$OUT/C_hub_light.png
run style=C screen=main light=1 out=$OUT/C_main_light.png
