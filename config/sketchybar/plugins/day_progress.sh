#!/bin/bash

# --- Day Progress for Sketchybar ---
# This script calculates the percentage of the day that has passed
# and updates a Sketchybar item with the result.

# Get the current hour, minute, and second from the 'date' command.
hour=$(date +'%H')
minute=$(date +'%M')
second=$(date +'%S')

# Calculate the total number of seconds that have passed since midnight.
# We use the '10#' prefix to ensure that numbers like '08' or '09' are
# interpreted as base-10, not as invalid octal numbers.
total_seconds_passed=$((10#$hour * 3600 + 10#$minute * 60 + 10#$second))

# The total number of seconds in a 24-hour day. 
total_seconds_in_day=86400

# Calculate the percentage.
# We use 'awk' because standard shell arithmetic doesn't handle floating-point
# numbers. 'awk' performs the division, multiplies by 100, and then
# 'printf "%.0f"' formats the result as a rounded integer (0 decimal places).
percentage=$(awk "BEGIN {printf \"%.0f\", ($total_seconds_passed / $total_seconds_in_day) * 100}")

# Set the label of the Sketchybar item.
# The '$NAME' variable is automatically provided by Sketchybar and contains the
# name of the item that triggered this script (e.g., "day_progress").
sketchybar --set $NAME label="${percentage}%"

