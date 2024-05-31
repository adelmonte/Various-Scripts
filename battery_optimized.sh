#!/bin/bash

# Truncate the configuration file
truncate -s 0 /etc/sysctl.d/99-kernel-optimized.conf

# CPU Scheduler and Frequency Scaling
echo "kernel.sched_autogroup_enabled=0" >> /etc/sysctl.d/99-kernel-optimized.conf

# Virtual Memory and Disk I/O
echo "vm.dirty_ratio=30" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "vm.dirty_background_ratio=10" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "vm.dirty_writeback_centisecs = 6000" >> /etc/sysctl.d/99-kernel-optimized.conf

# Laptop Mode
echo "vm.laptop_mode = 5" >> /etc/sysctl.d/99-kernel-optimized.conf

# Apply the changes
sysctl --system
