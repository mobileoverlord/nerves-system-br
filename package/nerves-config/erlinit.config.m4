# Additional configuration for erlinit
# Autogenerated - see package/nerves-config/erlinit.config.m4 for template

# Turn on the debug prints
ifelse(VERBOSE_INIT, `y', `-v', `#-v')

# Specify the UART port that the shell should use.
-c PORT

# If more than one tty are available, always warn if the user is looking at
# the wrong one.
--warn-unused-tty

# Use dtach to capture the iex session so that it can be redirected
# to the app's GUI
#-s "/usr/bin/dtach -N /tmp/iex_prompt"

# Uncomment to hang the board rather than rebooting when Erlang exits
ifelse(HANG_ON_EXIT, `y', `-h', `#-h')

# Enable UTF-8 filename handling in Erlang and custom inet configuration
-e LANG=en_US.UTF-8;LANGUAGE=en;ERL_INETRC=/etc/erl_inetrc

# Mount the application partition
# See http://www.linuxfromscratch.org/lfs/view/6.3/chapter08/fstab.html about
# ignoring warning the Linux kernel warning about using UTF8 with vfat.
ifelse(EXTRA_MOUNTS, `', `#-m /dev/mmcblk0p3:/mnt:vfat::utf8', `-m EXTRA_MOUNTS')

# Erlang release search path
ifelse(RELEASE_PATHS, `', `#-r /srv/erlang', `-r RELEASE_PATHS')

# Hostname
ifelse(UNIQUEID_PROG, `', `#-d "/usr/bin/nerves-id 4"', `-d UNIQUEID_PROG')
ifelse(HOSTNAME_PATTERN, `', `#-n nerves-%.4s', `-n HOSTNAME_PATTERN')
