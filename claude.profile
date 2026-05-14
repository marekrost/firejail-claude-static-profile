# ~/.config/firejail/claude.profile
#
# Optimized to run without need for SUID firejail.
# Without SUID the following filtering is not possible:
#   - Disabling access to X11
#   - Controlling access to network and localhost network services
#
# To provide access to the current working directory add the following alias:
#   alias claude='firejail --profile=~/.config/firejail/claude.profile --whitelist="$(pwd)" ~/.local/bin/claude'
#


# Security hardening
caps.drop all                                          # Drop all capabilities
allusers                                               # Permits /home/linuxbrew, raises warning on private-etc, NOT recommended on multi-user systems
nonewprivs                                             # Prevent privilege escalation
noroot                                                 # Prevent root access
seccomp                                                # Apply the default seccomp-bpf filter (blocks dangerous syscalls)
private-tmp                                            # Private /tmp directory
private-dev                                            # Mount a minimal /dev (no raw devices, kvm, etc.)
net default                                            # Requires SUID: Network isolation
netfilter                                              # Requires SUID: Default iptables firewall
protocol unix,inet,inet6                               # Drop netlink/packet/bluetooth/etc. socket families
nosound                                                # Disable access to /dev/snd and audio servers (PulseAudio/PipeWire)
no3d                                                   # Disable GPU access (/dev/dri, /dev/nvidia*)
nogroups                                               # Don't inherit supplementary groups
dbus-user none                                         # Block all session-bus traffic (no portals, notifications, secrets API)
dbus-system none                                       # Block all system-bus traffic (no systemd, NetworkManager, etc.)
restrict-namespaces user,net,mnt,ipc,cgroup,uts,pid    # Prevents the sandbox from creating its own namespaces
machine-id                                             # Spoof machine ID
hostname claude                                        # Do not leak hostname
ipc-namespace                                          # Do not share System V IPC and POSIX shared memory with the host

# Configurations
noblacklist ${HOME}/.config/gh
whitelist ${HOME}/.config/gh

# System path access
include disable-common.inc
include disable-programs.inc

# Linuxbrew utilities
whitelist /home/linuxbrew/.linuxbrew/Cellar
whitelist /home/linuxbrew/.linuxbrew/etc
whitelist /home/linuxbrew/.linuxbrew/lib
whitelist /home/linuxbrew/.linuxbrew/opt
whitelist /home/linuxbrew/.linuxbrew/share
whitelist /home/linuxbrew/.linuxbrew/bin/gh
whitelist /home/linuxbrew/.linuxbrew/bin/mise
whitelist /home/linuxbrew/.linuxbrew/bin/uv
whitelist /home/linuxbrew/.linuxbrew/bin/uvx
read-only /home/linuxbrew/.linuxbrew

# Developer runtimes
whitelist ${HOME}/.local/share/mise
whitelist ${HOME}/.local/share/uv
whitelist ${HOME}/.cache/uv
read-only ${HOME}/.local/share/mise
read-only ${HOME}/.local/share/uv

# Claude and data persistence
mkdir ${HOME}/.claude
whitelist ${HOME}/.claude
whitelist ${HOME}/.claude.json
whitelist ${HOME}/.local/bin/claude
read-only ${HOME}/.local/bin

# Private etc to prevent sensitive host info leaks
private-etc alternatives,ca-certificates,crypto-policies,group,gh,host.conf,hostname,hosts,ld.so.cache,ld.so.conf,ld.so.conf.d,ld.so.preload,locale,locale.alias,locale.conf,localtime,login.defs,mime.types,nsswitch.conf,passwd,pki,protocols,resolv.conf,rpc,services,ssl,xdg
