**99-power.rules** - A udev rule for managing laptop power state changes (connect/disconnect of power supply). It triggers the cpupower-control.sh script to adjust settings accordingly.

**cpupower-control.sh** - Script that modifies Intel power settings based on the laptop's power connection status, using cpupower-gui for adjustments.

**bluetooth_sleep.sh** - Script that turns off Bluetooth, and optionally closes Spotify and JamesDSP, when the laptop lid is closed.

**bluetooth_toggle.sh** - Script that toggles the activation state of Bluetooth, Spotify, and JamesDSP simultaneously, either turning all on or all off.

**brightness-d.sh & brightness-i.sh** - Scripts that smoothly adjust the laptop's backlight using brillo, and display an XFCE notification with a dynamic icon.

**centerx.sh** - Script that centers an X11 window on the screen, adjusting automatically for different resolutions.

**fadein.sh** - Startup script that gradually increases the backlight brightness at login, integrated with XFCE4 environment.

**home-end.sh** - Keybinding script that toggles the functionality between Home and End on the same key, storing the current state in .home_end_toggle in the user's home directory.

**pagedown.sh & pageup.sh** - Scripts providing keybindings for navigating pages up or down.

**removeprivate.sh** - Script that deletes an empty folder left behind by the gocryptfs-ui timer, triggered during login and suspend events in XFCE.
