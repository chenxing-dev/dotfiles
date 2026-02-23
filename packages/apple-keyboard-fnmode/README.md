### apple-keyboard-fnmode

This package is a fix for certain keyboard F-keys not working due to the keyboard having Apple IDs and `hid_apple` is loaded. 

#### Potential Cause

- **Kernel driver quirks** (common for Apple-ID keyboards): the kernel may intentionally translate the F-row into brightness/volume/media keycodes.
  - Example: `hid_apple` can turn HID F1 (scan `7003a`) into `KEY_BRIGHTNESSDOWN`.

#### How to diagnose (fastest → deepest)

1. **Does it fail outside your compositor?**
   - If it fails in a TTY too, it’s not a compositor issue.
   - If you can’t reach a TTY with `Ctrl+Alt+F3`, use `sudo chvt 3`.
2. **Do scancodes appear?**
   - `sudo showkey --scancodes` (in a TTY)
   - If nothing prints for F1–F12, look at BIOS/UEFI “Fn / Hotkey / Action keys mode”.
3. **What keycode is it mapped to?**
   - `sudo evtest /dev/input/by-id/<kbd>-event-kbd`
   - Look for `MSC_SCAN` and the `EV_KEY` code.
   - If it says `KEY_BRIGHTNESSDOWN`, `KEY_VOLUMEUP`, etc. then your “F-keys” are media keys.
4. **Apple-ID / hid_apple check**
   - `lsmod | grep hid_apple`
   - `cat /sys/module/hid_apple/parameters/fnmode`
   - `modinfo -p hid_apple` (shows what the `fnmode` values mean)

#### Fix

- Set F-keys first:
  - Persist: `/etc/modprobe.d/hid_apple.conf` → `options hid_apple fnmode=2`
  - Apply: reboot, or reload the module.
