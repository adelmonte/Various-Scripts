#!/bin/bash

# Truncate the configuration file
truncate -s 0 /etc/sysctl.d/99-kernel-optimized.conf

# CPU Scheduler and Frequency Scaling
echo "kernel.sched_autogroup_enabled=1" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "kernel.sched_migration_cost_ns=5000000" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "kernel.sched_min_granularity_ns=10000000" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "kernel.sched_wakeup_granularity_ns=15000000" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "kernel.sched_features=0x04,~0x20" >> /etc/sysctl.d/99-kernel-optimized.conf

# Virtual Memory and Disk I/O
echo "vm.dirty_ratio=10" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "vm.dirty_background_ratio=5" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "vm.swappiness=10" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.d/99-kernel-optimized.conf

# Network kernel
echo "net.core.rmem_max=67108864" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "net.core.wmem_max=67108864" >> /etc/sysctl.d/99-kernel-optimized.conf
echo "net.ipv4.tcp_fastopen=3" >> /etc/sysctl.d/99-kernel-optimized.conf

# Kernel Sampler
echo "kernel.perf_cpu_time_max_percent=25" >> /etc/sysctl.d/99-kernel-optimized.conf

# Preemption
echo "kernel.preempt_max_cpu_resv_pct=50" >> /etc/sysctl.d/99-kernel-optimized.conf

# Apply the changes
sysctl --system