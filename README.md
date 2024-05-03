**99-power.rules** - udev rule for laptop powerchange event (plug and unplug) which calls script cpupower-control.sh

**cpupower-control.sh** - changes intel power settings using cpupower-gui based on plugged/unplugged status

**bluetooth_sleep.sh** - disables bluetooth and optionally closes spotify and jamesdsp upon closing the lid

**bluetooth_toggle.sh** - smart keybind for opening or closing spotify, jamesdsp, and bluetooth - all on or all off regardless of state

**brightness-d.sh & brightness-i.sh** - use brillo to adjust laptop backlight SMOOTHLY and creates XFCE notification with scaling icon calls

**centerx.sh** - centers x11 window to center screen (adjust for resolution)

**fadein.sh** - startup script to fade in backlight w/ XFCE4

**home-end.sh** - keybind for toggling home/end on same key back and forth (depends on .home_end_toggle in home directory to store state)

**pagedown.sh & pageup.sh** - keybinds for page up/down

**removeprivate.sh** - remove empty folder left by gocryptfs-ui timer _if folder is empty_ (bound to login and suspend in XFCE)
