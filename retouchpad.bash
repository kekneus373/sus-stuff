#!/usr/bin/env bash
echo "Disabling touchpad..."
sudo modprobe -r psmouse
echo "Enabling touchpad..."
sudo modprobe psmouse
echo "Should work now. Otherwise, check 'dmesg' or reboot"
