#!/usr/bin/env bash
interfaces=$(ls -1 /sys/class/backlight)

for interface in $interfaces; do
  maxBrightness=$(cat /sys/class/backlight/$interface/max_brightness)
  brightness=$(cat /sys/class/backlight/$interface/brightness)
  echo "$interface,$brightness,$maxBrightness"
done
