-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.enable_tab_bar = false

config.color_scheme = "Github"
config.colors = {
    background = "#ffffff",
    ansi = {
        "#0e1116","#a0111f","#024c1a","#3f2200","#0349b4","#622cbc","#1b7c83","#66707b"
    },
    brights = {"#4b535d","#86061d","#055d20","#4e2c00","#1168e3","#844ae7","#3192aa","#88929d"}
}

config.font = wezterm.font_with_fallback{
    'FiraCode Nerd Font',
    'Noto Sans Mono CJK SC'
}

-- and finally, return the configuration to wezterm
return config