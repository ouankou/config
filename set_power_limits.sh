#!/bin/bash

# Start at boot
# sudo crontab -e
# @reboot /home/ouankou/Projects/config/set_power_limits.sh 100 2
#
# thermald service may override the PL1 setting (e.g., from 60W to 200W).
# In this case, it should be disabled.
# sudo systemctl stop thermald
# sudo systemctl disable thermald

# Default power limit in watts (if no argument is given)
DEFAULT_WATTS=60

# Default number of CPUs (if no argument is given)
DEFAULT_CPUS=1

# Get user input (first argument), default to DEFAULT_WATTS if not provided
POWER_LIMIT_WATTS=${1:-$DEFAULT_WATTS}

# Convert watts to micro-watts (1W = 1,000,000μW)
POWER_LIMIT_UW=$(($POWER_LIMIT_WATTS * 1000000))

# Use the second argument for number of CPUs if provided, otherwise default to DEFAULT_CPUS
NUM_CPUS="${2:-$DEFAULT_CPUS}"

# Validate that POWER_LIMIT is a positive number
if ! [[ "$DEFAULT_WATTS" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "Error: power_limit must be a positive number."
    exit 1
fi

# Validate that NUM_CPUS is a positive integer
if ! [[ "$NUM_CPUS" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: num_cpus must be a positive integer."
    exit 1
fi

# Loop through each CPU and set the power limits for both PL1 and PL2
for (( i=0; i<NUM_CPUS; i++ )); do
    echo "Setting PL1 and PL2 for CPU $i to ${POWER_LIMIT_WATTS}W"
    # Example: write the power limit to the CPU's power limit files.
    # Update the paths as needed for your system.

    # PowerCap directory (adjust if needed)
    POWER_LIMIT_DIR="/sys/class/powercap/intel-rapl/intel-rapl:$i"

    # Check if PowerCap interface exists
    if [ ! -d "$POWER_LIMIT_DIR" ]; then
        echo "Error: PowerCap interface not found at $POWER_LIMIT_DIR"
        exit 1
    fi

    echo "Setting power limits to ${POWER_LIMIT_WATTS}W (${POWER_LIMIT_UW}μW)..."

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
done

echo "Applied ${POWER_LIMIT_WATTS}W to PL1 and PL2 on $NUM_CPUS CPU(s)."
