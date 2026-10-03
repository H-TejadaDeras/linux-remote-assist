#!/bin/bash
# Made by Claude Code + Henry Tejada Deras - 07-04-2026
# Validated on Ubuntu 24.04 LTS
set -e

echo "\nStarting Remote Assist Portal\n"
echo "Version 1.1 - 07-04-2026\n"

if [ "$EUID" -ne 0 ]; then
  echo "Please run with sudo"
  exit 1
fi

# Extract user and display from `who` output
WHO_LINE=$(who | grep -m1 '(:[0-9]\+)')

if [ -z "$WHO_LINE" ]; then
  echo "No active X session found, exiting"
  exit 1
fi

ACTIVE_USER=$(echo "$WHO_LINE" | awk '{print $1}')
ACTIVE_DISPLAY=$(echo "$WHO_LINE" | grep -oP '(?<=\()[^)]+(?=\))')

if [ -z "$ACTIVE_USER" ] || [ -z "$ACTIVE_DISPLAY" ]; then
  echo "Could not parse user/display, exiting"
  exit 1
fi

echo "Detected user: $ACTIVE_USER, display: $ACTIVE_DISPLAY"

XAUTH_PATH="/home/$ACTIVE_USER/.Xauthority"

if [ ! -f "$XAUTH_PATH" ]; then
  echo "Xauthority not found at $XAUTH_PATH, exiting"
  exit 1
fi

x11vnc \
  -display "$ACTIVE_DISPLAY" \
  -auth "$XAUTH_PATH" \
  -rfbauth /etc/x11vnc.pass \
  -localhost \
  -once \
  -noxdamage