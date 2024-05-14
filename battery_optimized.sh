#!/bin/bash

# Truncate the configuration file
truncate -s 0 /etc/sysctl.d/99-kernel-optimized.conf

# CPU Scheduler and Frequency Scaling
echo "kernel.sched_autogroup_enabled=0" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "kernel.sched_migration_cost_ns=5000000" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "kernel.sched_min_granularity_ns=10000000" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "kernel.sched_wakeup_granularity_ns=15000000" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "kernel.sched_energy_awared=1" >> /etc/sysctl.d/99-kernel-optimized.conf

# Virtual Memory and Disk I/O
echo "vm.dirty_ratio=30" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "vm.dirty_background_ratio=10" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "vm.swappiness=80" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "vm.vfs_cache_pressure=100" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "vm.dirty_writeback_centisecs = 6000" >> /etc/sysctl.d/99-kernel-optimized.conf

# CPU Frequency Scaling
echo "kernel.sched_cpufreq_util_plugin=1" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "kernel.sched_cpufreq_elc.llpml=1" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "kernel.sched_cpufreq_elc.pm_qos_no_authority=1" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "kernel.sched_cpufreq_util_data.cpu_util_sum_allowed_cpu_buck_ratio=8" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "kernel.nmi_watchdog=0" >> /etc/sysctl.d/99-kernel-optimized.conf

# Laptop Mode
echo "vm.laptop_mode = 5" >> /etc/sysctl.d/99-kernel-optimized.conf

# Apply the changes
sysctl --system
