#include <tunables/global>

profile koad-restricted flags=(attach_disconnected,mediate_deleted) {
  #include <abstractions/base>
  #include <abstractions/nameservice>

  # Deny all file writes except /tmp
  deny /etc/** w,
  deny /usr/** w,
  deny /bin/** w,
  deny /sbin/** w,
  deny /root/** w,
  deny /home/** w,

  # Allow /tmp writes
  /tmp/** rw,

  # Deny network raw access (prevents nmap SYN scan)
  deny network raw,

  # Deny mount operations (prevents escape S13-S18)
  deny mount,
  deny umount,

  # Deny ptrace (prevents S17)
  deny ptrace,

  # Deny access to sensitive paths
  deny /proc/sys/kernel/core_pattern w,
  deny /var/run/docker.sock rw,
  deny /proc/sysrq-trigger w,

  # Allow read for normal operations
  /proc/** r,
  /sys/** r,
  /dev/null rw,
  /dev/zero r,
  /dev/urandom r,
}
