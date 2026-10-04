---@diagnostic disable-next-line: undefined-global
---- MONITORS ----
-- See https://wiki.hypr.land/configuring/core/monitors/
hl.monitor({
	output = "DP-3",
	mode = "1920x1080@180",
	position = "auto",
	scale = "1.0",
})

hl.monitor({
	output = "eDP-1",
	mode = "1920x1080@60",
	position = "auto",
	scale = "1.0",
})

---- AUTOSTART ----
-- See https://wiki.hypr.land/configuring/core/autostart/
hl.on("hyprland.start", function()
	hl.exec_cmd("nm-applet")
	hl.exec_cmd("librewolf")
	hl.exec_cmd("waybar")
	hl.exec_cmd("swaybg -i ~/sync/pictures/mt.jpeg -m fill")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

---- ENVIRONMENT VARIABLES ----
-- See https://wiki.hypr.land/configuring/core/environment-variables/
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
	general = {
		gaps_out = 4,
		gaps_in = 2,

		border_size = 1,
		col = {
			active_border = "#000000",
			inactive_border = "#4F5258",
		},
		resize_on_border = true,

		allow_tearing = true,

		layout = "master",
	},

	master = {
		mfact = 0.55,
		new_status = "master",
		orientation = "left",
	},

	render = { direct_scanout = 2 },
	cursor = {
		no_warps = true,
		no_hardware_cursors = false,
	},

	decoration = {
		rounding = 0,
		rounding_power = 0,

		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = false,
		},

		blur = {
			enabled = false,
		},
	},

	animations = { enabled = false },
})

----  MISC  ----
hl.config({
	misc = {
		force_default_wallpaper = 0,
		disable_splash_rendering = true,
		disable_hyprland_logo = true,
	},
})

---- INPUT ----
hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "ctrl:nocaps",
		kb_rules = "",

		follow_mouse = 1,

		sensitivity = 0,
		accel_profile = "flat",

		touchpad = {
			natural_scroll = false,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Example per-device config
-- See https://wiki.hypr.land/configuring/core/devices/ for more
hl.device({
	name = "epic-mouse-v1",
	sensitivity = 0.0,
})

---- KEYBINDINGS ----
local mainMod = "SUPER"

hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("fuzzel"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("librewolf"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("ghostty"))
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("/home/br1yen/.local/bin/powermenu"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("/home/br1yen/.local/bin/fzfpdf"))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Return", hl.dsp.layout("swapwithmaster"))
hl.bind(mainMod .. " + M", hl.dsp.layout("focusmaster"))
hl.bind(mainMod .. " + H", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ workspace = "m-1" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ workspace = "m+1" }))
hl.bind(mainMod .. " + J", hl.dsp.layout("cyclenext"))
hl.bind(mainMod .. " + K", hl.dsp.layout("cycleprev"))
hl.bind(mainMod .. " + Tab", hl.dsp.layout("rollnext"))
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.layout("rollprev"))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("swapnext"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.layout("swapprev"))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.layout("addmaster"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.layout("removemaster"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.layout("orientationleft"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.layout("orientationright"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.layout("orientationtop"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.layout("orientationbottom"))
hl.bind(mainMod .. " + minus", hl.dsp.layout("mfact -0.05"))
hl.bind(mainMod .. " + equal", hl.dsp.layout("mfact +0.05"))

-- toggle waybar
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())

hl.bind(mainMod .. " + M", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
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

-- Screenshot to clipboard
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

-- Screenshot to file
hl.bind(
	mainMod .. " + SHIFT + S",
	hl.dsp.exec_cmd('grim -g "$(slurp)" ~/Pictures/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png')
)

-- Clipboard history
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("sh -c 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy'"))

---- WINDOWS AND WORKSPACES ----
-- See https://wiki.hypr.land/configuring/core/rules/
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
	name = "librewolf-workspace",
	match = { class = "^librewolf$" },
	workspace = "2",
})

hl.window_rule({
	name = "pavucontrol",
	match = { class = "^(org.pulseaudio.pavucontrol)$" },
	float = true,
	center = true,
})

hl.window_rule({
	name = "cs2-gaming",
	match = { class = "^cs2$" },
	fullscreen = true,
	immediate = true,
	idle_inhibit = "fullscreen",
	no_anim = true,
	no_blur = true,
	no_shadow = true,
})
