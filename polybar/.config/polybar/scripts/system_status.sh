#!/usr/bin/env bash

# CPU usage and memory
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')%
mem_usage=$(free -h | awk '/Mem:/ {print $3 "/" $2}')

# CPU temperature and fan
cpu_temp=$(sensors | awk '/Tctl:/ {print $2}' | head -n1)
cpu_fan=$(sensors | awk '/fan1:/ {print $2 " RPM"}' | head -n1)
sys_fan=$(sensors | awk '/fan2:/ {print $2 " RPM"}' | head -n1)

# GPU temperature, power, and fan speed using NVIDIA tools
gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader | head -n1)
gpu_power=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader | head -n1)
gpu_fan=$(nvidia-smi --query-gpu=fan.speed --format=csv,noheader | head -n1)

# Show system status notification
notify-send -t 10000 "System Status" \
"CPU Usage: $cpu_usage
Memory Usage: $mem_usage
CPU Temp: $cpu_temp
CPU Fan: $cpu_fan
SYS Fan: $sys_fan
GPU Temp: ${gpu_temp}°C
GPU Power: $gpu_power
GPU Fan: $gpu_fan"

    echo "Script triggered at $(date)" >>/tmp/polybar_debug.log
