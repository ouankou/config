#!/bin/bash

# Start at boot
# sudo crontab -e
# @reboot /home/ouankou/Projects/config/set_power_limits.sh
#
# thermald service may override the PL1 setting (e.g., from 60W to 200W).
# In this case, it should be disabled.
# sudo systemctl stop thermald
# sudo systemctl disable thermald

# Default power limit in watts (if no argument is given)
DEFAULT_WATTS=60

# Get user input (first argument), default to DEFAULT_WATTS if not provided
POWER_LIMIT_WATTS=${1:-$DEFAULT_WATTS}

# Convert watts to micro-watts (1W = 1,000,000μW)
POWER_LIMIT_UW=$(($POWER_LIMIT_WATTS * 1000000))

# PowerCap directory (adjust if needed)
POWER_LIMIT_DIR="/sys/class/powercap/intel-rapl/intel-rapl:0"

# Check if PowerCap interface exists
if [ ! -d "$POWER_LIMIT_DIR" ]; then
    echo "Error: PowerCap interface not found at $POWER_LIMIT_DIR"
    exit 1
fi

echo "Setting power limits to ${POWER_LIMIT_WATTS}W (${POWER_LIMIT_UW} μW)..."

# Set PL1 (long-term power limit)
if [ -f "$POWER_LIMIT_DIR/constraint_0_power_limit_uw" ]; then
    echo $POWER_LIMIT_UW | sudo tee "$POWER_LIMIT_DIR/constraint_0_power_limit_uw" > /dev/null
    echo "PL1 set to ${POWER_LIMIT_WATTS}W"
else
    echo "Error: PL1 constraint file not found."
fi

# Set PL2 (short-term power limit)
if [ -f "$POWER_LIMIT_DIR/constraint_1_power_limit_uw" ]; then
    echo $POWER_LIMIT_UW | sudo tee "$POWER_LIMIT_DIR/constraint_1_power_limit_uw" > /dev/null
    echo "PL2 set to ${POWER_LIMIT_WATTS}W"
else
    echo "Error: PL2 constraint file not found."
fi
