**99-power.rules** - A udev rule for managing laptop power state changes (connect/disconnect of power supply). It triggers the cpupower-control.sh script to adjust settings accordingly.

**cpupower-control.sh** - Modifies Intel power settings based on the laptop's power connection status, using cpupower-gui for adjustments.

**bluetooth_sleep.sh** - Turns off Bluetooth, and optionally closes Spotify and JamesDSP (trigger with laptop lid closing event).

**bluetooth_toggle.sh** - Toggle the activation state of Bluetooth, Spotify, and JamesDSP simultaneously, either turning all on or all off.

**brightness-d.sh & brightness-i.sh** - Smoothly adjust the laptop's backlight using brillo, and display an XFCE notification with a dynamic icon.

**centerx.sh** - Centers active X11 window on the screen.

**fadein.sh** - Startup script that gradually increases the backlight brightness at login.

**home-end.sh** - Keybinding that toggles the functionality between Home and End on the same key, storing the current state in .home_end_toggle in the user's home directory.

**pagedown.sh & pageup.sh** - Keybindings for navigating pages up or down.

**removeprivate.sh** - Script that deletes an empty folder left behind by the gocryptfs-ui timer (trigger with login and suspend events).
