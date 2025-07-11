# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
import subprocess

from libqtile import bar, layout, qtile, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal


@hook.subscribe.startup_once
def autostart():
    script = os.path.expanduser("~/.config/qtile/autostart.sh")
    subprocess.run([script])


def get_network_manager():
    """Determine which network manager is active"""
    try:
        # Check if NetworkManager is running
        nm_status = subprocess.run(
            ["systemctl", "is-active", "NetworkManager"],
            capture_output=True, text=True
        ).stdout.strip()

        # Check if iwd is running
        iwd_status = subprocess.run(
            ["systemctl", "is-active", "iwd"],
            capture_output=True, text=True
        ).stdout.strip()

        # Prioritize NetworkManager if both are active
        if nm_status == "active":
            return os.path.expanduser("~/.local/bin/rofi-nmcli")
        elif iwd_status == "active":
            return os.path.expanduser("~/.local/bin/rofi-iwctl")

        # Check for installed commands as fallback
        if subprocess.run(["which", "nmcli"], stdout=subprocess.DEVNULL).returncode == 0:
            return os.path.expanduser("~/.local/bin/rofi-nmcli")
        elif subprocess.run(["which", "iwctl"], stdout=subprocess.DEVNULL).returncode == 0:
            return os.path.expanduser("~/.local/bin/rofi-iwctl")
    except Exception:
        pass

    # Default fallback
    return os.path.expanduser("~/.local/bin/rofi-nmcli")


mod = "mod4"
terminal = "wezterm"

# Screenshot directory setup
screenshot_dir = os.path.expanduser("~/Pictures/Screenshots")
os.makedirs(screenshot_dir, exist_ok=True)

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    # Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(),
        desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(),
        desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(),
        desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(),
        desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),

    # Launchers
    Key([mod], "b", lazy.spawn(os.path.expanduser(
        "~/.local/bin/rofi-url")), desc="Url bookmark launcher"),
    Key([mod], "c", lazy.spawn(os.path.expanduser(
        "~/.local/bin/rofi-code")), desc="Open repos in VS Code"),
    Key([mod], "d", lazy.spawn("rofi -show drun"), desc="Application launcher"),
    Key([mod,], "e", lazy.spawn("wezterm start -- yazi"),
        desc="Launch Yazi file manager"),
    Key([mod, "shift"], "e", lazy.spawn(os.path.expanduser(
        "~/.local/bin/rofi-system")), desc="Power menu"),
    Key([mod], "n", lazy.spawn(get_network_manager()),
        desc="Launch network manager"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),

    # Screenshot
    Key([], "Print", lazy.spawn(
        f"scrot '{screenshot_dir}/%Y-%m-%d_%H-%M-%S_full.png' "
        "-e 'notify-send \"Screenshot\" \"Fullscreen captured \n$f\" -i camera-photo'"
    ), desc="Fullscreen screenshot"),
    Key(["shift"], "Print", lazy.spawn(
        f"scrot -s '{screenshot_dir}/%Y-%m-%d_%H-%M-%S_area.png' "
        "-e 'notify-send \"Screenshot\" \"Selected area captured \n$f\" -i camera-photo'"
    ), desc="Region selection screenshot"),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),

    Key([mod], "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
        ),
    Key([mod], "t", lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(
                func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )

group_labels = {
    "1": "󰈹",
    "2": "",
    "3": "󰝚",
    "4": "󰵅",
    "5": "󰊖",
    "6": "",
}

groups = [Group(name, label=label) for name, label in group_labels.items()]

for i in groups:
    keys.extend(
        [
            # mod + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc=f"Switch to group {i.name}",
            ),
            # mod + shift + group number = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
        ]
    )

layouts = [
    layout.Columns(
        border_focus='#666666',
        border_normal='#000000',
        border_width=1,
        border_on_single=True,
        margin=10
    ),
    layout.Max(
        border_focus='#666666',
        border_normal='#000000',
        border_width=1,
    ),
    layout.Bsp(
        border_focus='#666666',
        border_normal='#000000',
        border_width=1,
        border_on_single=True,
        margin=10
    ),
]

widget_defaults = dict(
    font="FiraCode Nerd Font",
    fontsize=12,
    padding=4,
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        wallpaper=os.path.expanduser("~/.config/qtile/wallpaper.png"),
        wallpaper_mode='stretch',
        bottom=bar.Bar(
            [
                widget.GroupBox(
                    highlight_method='text',
                    this_current_screen_border='FFFFFF',
                    fontsize=14,
                    margin_y=4,
                    padding_x=6,
                ),
                widget.Prompt(),
                widget.WindowName(),
                widget.Chord(
                    chords_colors={
                        "launch": ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                # widget.StatusNotifier(),
                widget.Systray(),
                widget.Wlan(
                    format='{essid}'
                ),
                widget.Clock(format="%a %d %b %H:%M"),
                # widget.QuickExit(),
            ],
            28,
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
        # You can uncomment this variable if you see that on X11 floating resize/moving is laggy
        # By default we handle these events delayed to already improve performance, however your system might still be struggling
        # This variable is set to None (no cap) by default, but you can set it to 60 to indicate that you limit it to 60 events per second
        # x11_drag_polling_rate = 60,
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ],
    border_focus='#666666',
    border_normal='#000000',
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = None
wl_xcursor_size = 24

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
