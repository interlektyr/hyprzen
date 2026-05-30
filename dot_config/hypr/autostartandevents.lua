------------------------------------
---- AUTOSTART AND OTHER EVENTS ----
------------------------------------

-- For Autostart: See https://wiki.hypr.land/Configuring/Basics/Autostart/.
-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function()
	hl.exec_cmd("udisks2 &")
	hl.exec_cmd("udiskie &")
	hl.exec_cmd("/usr/bin/dunst &")
	hl.exec_cmd("awww-daemon &")
	hl.exec_cmd("kitty --title dropdterm -e fish", { workspace = "special:terminal silent" })
	hl.exec_cmd("zen-browser --start-fullscreen", { workspace = "special:zbrowser silent" })
	hl.exec_cmd("quickshell &")
	hl.dispatch(hl.dsp.focus({ workspace = "1" }))
	--hl.exec_cmd("kanshi &")
end)

-- Autostart (or "hyprland.start") is only one of several event:

--hl.on("monitor.removed", function()
--	hl.exec_cmd("~/.config/hypr/hyp_mon.sh")
--	hl.exec_cmd("hyprctl reload")
--end)

--hl.on("config.reloaded", function()
--	hl.exec_cmd("udisks2 &")
--	hl.exec_cmd("udiskie &")
--	hl.exec_cmd("awww-daemon &")
--	hl.exec_cmd("quickshell &")
--hl.exec_cmd("hdrop -b kitty -class kitty_1")
--end)

hl.on("workspace.active", function()
	local getCurrentWc = hl.get_active_workspace()

	if getCurrentWc.name == "2" then
		hl.config({
			general = { col = { active_border = "rgba(219, 230, 175, 1)" } },
		})
	elseif getCurrentWc.name == "3" then
		hl.config({
			general = { col = { active_border = "rgba(202, 224, 167, 1)" } },
		})
	elseif getCurrentWc.name == "4" then
		hl.config({
			general = { col = { active_border = "rgba(173, 222, 185, 1)" } },
		})
	elseif getCurrentWc.name == "5" then
		hl.config({
			general = { col = { active_border = "rgba(172, 224, 212, 1)" } },
		})
	elseif getCurrentWc.name == "6" then
		hl.config({
			general = { col = { active_border = "rgba(175, 223, 230, 1)" } },
		})
	elseif getCurrentWc.name == "7" then
		hl.config({
			general = { col = { active_border = "rgba(178, 207, 237, 1)" } },
		})
	elseif getCurrentWc.name == "8" then
		hl.config({
			general = { col = { active_border = "rgba(208, 187, 240, 1)" } },
		})
	elseif getCurrentWc.name == "9" then
		hl.config({
			general = { col = { active_border = "rgba(243, 192, 229, 1)" } },
		})
	elseif getCurrentWc.name == "10" then
		hl.config({
			general = { col = { active_border = "rgba(248, 249, 232, 1)" } },
		})
	else
		hl.config({
			general = { col = { active_border = "rgba(245,208,152,1)" } },
		})
	end
end)
