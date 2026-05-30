--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

-- No border when only one window on a workspace
hl.window_rule({ match = { workspace = "w[v1]" }, border_size = 0 })
hl.window_rule({ match = { workspace = "f[1]" }, border_size = 0 })
--hl.window_rule({ match = { workspace = "2" }, active_border = "rgba(219,230,175,1)" })

local suppressMaximizeRule = hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

hl.window_rule({
	name = "handle-yazi_as_filepicker",
	match = { class = "kitty", title = "yazi_filepicker" },
	float = true,
	size = { "(monitor_w*0.85)", "(monitor_h*0.85)" },
	--stay_focused = true,
})

hl.window_rule({
	name = "handle-kitty",
	match = { class = "kitty", title = "stand_alone" },
	float = true,
	size = { "(monitor_w*0.75)", "(monitor_h*0.75)" },
})

hl.layer_rule({
	match = { namespace = "notifications" },
	hl.animation(
		{ leaf = "layersIn", enabled = true, speed = 2.5, bezier = "almostLinear", style = "slide" },
		{ leaf = "layersOut", enabled = true, speed = 2.5, bezier = "almostLinear", style = "slide" }
	),
})
