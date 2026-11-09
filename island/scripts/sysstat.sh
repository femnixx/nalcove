#!/bin/sh
head -n1 /proc/stat
awk '/^MemTotal/{t=$2} /^MemAvailable/{a=$2} END{print "MEM:" t " " a}' /proc/meminfo

temp=""
for h in /sys/class/hwmon/hwmon*; do
  case "$(cat "$h/name" 2>/dev/null)" in
    coretemp|k10temp|zenpower) temp=$(cat "$h/temp1_input" 2>/dev/null); break ;;
  esac
done
[ -z "$temp" ] && temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
[ -n "$temp" ] && echo "TEMP:$temp"

for b in /sys/class/power_supply/BAT*; do
  [ -d "$b" ] || continue
  if [ -r "$b/power_now" ]; then
    echo "POWER:$(cat "$b/power_now")"
  elif [ -r "$b/current_now" ] && [ -r "$b/voltage_now" ]; then
    echo "POWER:$(( $(cat "$b/current_now") * $(cat "$b/voltage_now") / 1000000 ))"
  fi
  break
done

if [ "$1" = "gpu" ] && command -v nvidia-smi >/dev/null 2>&1; then
  echo "GPU:$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,power.draw --format=csv,noheader,nounits)"
fi