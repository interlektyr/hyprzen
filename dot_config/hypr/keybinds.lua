---------------------
---- KEYBINDINGS ----
---------------------
---

local mainMod = "SUPER"

---MAIN KEYBINDINGS
---Launch appcommander
hl.bind(mainMod .. " + SPACE", hl.dsp.global("quickshell:appcommander_hud"))
---Launch yazi, floating
hl.bind(mainMod .. " + CTRL + SPACE", hl.dsp.exec_cmd("kitty --title yazi_filepicker -e yazi"))
---Show clock
hl.bind(mainMod .. " + ALT + RETURN", hl.dsp.global("quickshell:clock_hud"))
---Show zen-browser drop-down
hl.bind(mainMod .. " + RETURN", hl.dsp.workspace.toggle_special("zbrowser"))
---Show terminal drop-down
hl.bind(mainMod .. " + CTRL + RETURN", hl.dsp.workspace.toggle_special("terminal"))
---Stand-alone kitty-terminal, floating
hl.bind(mainMod .. " + PERIOD", hl.dsp.exec_cmd("kitty"))

--MAIN APPS
--kitty terminal, tiled
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("kitty --title stand_alone"))
--yazi, tiled
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("kitty -e yazi"))
--neovim/neovide, tiled
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("neovide"))
--zenbrowser, tiled
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("zen-browser"))

---ZENSHELL
---Power
hl.bind(mainMod .. " + CTRL + DELETE", hl.dsp.global("quickshell:power_hud"))
---System
hl.bind(mainMod .. " + S", hl.dsp.global("quickshell:zensys_hud"))
---Volume
hl.bind(mainMod .. " + CTRL + V", hl.dsp.global("quickshell:volume_hud"))
---Battery
hl.bind(mainMod .. " + B", hl.dsp.global("quickshell:battery_hud"))
---Workspace
hl.bind(mainMod .. " + Control_R", hl.dsp.global("quickshell:workspace_hud"))
--{ release = true })
---Lockscreen
hl.bind(mainMod .. " + CTRL + L", hl.dsp.global("quickshell:lockTheScreen"))

---WINDOWS
---Focus follows mouse or move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), { click = true })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { click = true })
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), { click = true })
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), { click = true })
--cycle next/prev floating window
hl.bind(mainMod .. " + ALT + left", hl.dsp.window.cycle_next({ next = true, tiled = false, floating = true }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.cycle_next({ next = false, tiled = false, floating = true }))
--- Fire a drag event only after dragging for more than 10px, set in look and feel
--- SUPER + LMB: Move a window by dragging more than 10px.
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
--- SUPER + RMB: resize a windows by dragging more than 10px
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
---close window either by SUPER + C or SUPER + RMB click
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.close(), { mouse = true, click = true })
---Send window to special workspaces stash ("hide it")
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.move({ workspace = "special:stash", follow = false }))

--temp
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.workspace.toggle_special("stash"))

---LAYOUTS
--- SUPER + LMB: Floats a window by either SUPER + V or SUPER + LMB + clicking
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.float({ action = "toggle" }), { mouse = true, click = true })
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
---Pseudo
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
---Toggle split (dwindle only)
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
---Toggle fullscreen
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))

---WORKSPACES
-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
-- Scroll through existing workspaces with mainMod + CTRL + right/left arrow key
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "+1" }))
hl.bind(mainMod .. " + CTRL + left", hl.dsp.focus({ workspace = "-1" }))
-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + CTRL + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i }))
end
-- Change wallpaper for active workspace
hl.bind(
	mainMod .. " + CTRL + W",
	hl.dsp.exec_cmd("kitty --title stand_alone -e ~/.config/quickshell/scripts/zen_wallrizz_wrapper.sh")
)

-- Exit HYprland
hl.bind(
	mainMod .. " + M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioRaiseVolume", hl.dsp.global("quickshell:volume_hud"), { repeating = true })
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioLowerVolume", hl.dsp.global("quickshell:volume_hud"), { repeating = true })
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioMute", hl.dsp.global("quickshell:volume_hud"), { repeating = true })
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
