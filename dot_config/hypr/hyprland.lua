require("monitors")
require("autostartandevents")
require("environment")
require("permissions")
require("lookandfeel")
require("misc")
require("input")
require("windowsandworkspaces")
require("keybinds")

-- Added by hyprmoncfg: its generated monitor rules load last, so nothing before this can override the applied layout.
dofile(os.getenv("HOME") .. "/.config/hypr/hyprmoncfg-monitors.lua")
