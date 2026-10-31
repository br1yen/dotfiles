---@diagnostic disable: undefined-global

hl.monitor({ output = "DP-3", mode = "1920x1080@180.00Hz", position = "0x0", scale = 1.0 })
hl.monitor({ output = "eDP-1", mode = "1920x1080@60.00Hz", position = "0x0", scale = 1.0 })

hl.on("hyprland.start", function()
	hl.exec_cmd("foot --server")
	hl.exec_cmd("waybar")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hyprctl hyprpaper wallpaper ',~/sync/pictures/oak-bg.png,'")
	hl.exec_cmd("steam -silent")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "ComixCursors-White")
hl.env("HYPRCURSOR_THEME", "ComixCursors-White")

hl.config({
	general = {
		gaps_out = 20,
		gaps_in = 8,
		border_size = 1,
		col = {
			active_border = "#000000",
			inactive_border = "#000000",
		},
		allow_tearing = true,
		layout = "dwindle",
		resize_on_border = true,
	},

	dwindle = {
		preserve_split = true,
	},

	render = {
		direct_scanout = 2,
	},

	decoration = {
		rounding = 0,
		rounding_power = 1,

		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = true,
			color = "0x80000000",
			color_inactive = "0x40000000",
			offset = { 0, 2 },
			range = 22,
			render_power = 4,
			scale = 1.0,
			sharp = false,
		},

		blur = {
			enabled = false,
		},
	},

	animations = { enabled = false },

	group = {
		groupbar = {
			enabled = true,
			font_family = "Inconsolata Medium",
			font_size = 14,
			gaps_in = 0,
			gaps_out = 0,
			indicator_height = 0,
			text_color = "0xffffffff",
			text_color_inactive = "0xffa8a1be",
			text_color_locked_active = "0xff000000",
		},
		col = {
			border_active = "0xff000000",
			border_inactive = "0xff000000",
			border_locked_active = "0xff000000",
			border_locked_inactive = "0xff000000",
		},
	},

	binds = {
		movefocus_cycles_groupfirst = true,
	},

	misc = {
		force_default_wallpaper = 0,
		disable_splash_rendering = true,
		disable_hyprland_logo = true,
		bell_sound = "none",
		vrr = 0,
	},

	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "ctrl:nocaps",
		kb_rules = "",

		sensitivity = 0,
		accel_profile = "flat",

		touchpad = {
			natural_scroll = false,
		},
	},
})

--- Keybinds
local mainMod = "SUPER"

hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("~/.config/hypr/scripts/wmenu.sh"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("helium-browser"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("footclient"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SPACE", hl.dsp.window.float({ action = "toggle" }))

hl.bind(mainMod .. " + ALT + H", hl.dsp.layout("preselect l"))
hl.bind(mainMod .. " + ALT + L", hl.dsp.layout("preselect r"))
hl.bind(mainMod .. " + ALT + K", hl.dsp.layout("preselect u"))
hl.bind(mainMod .. " + ALT + J", hl.dsp.layout("preselect d"))

hl.bind(mainMod .. " + W", hl.dsp.group.toggle())
hl.bind(mainMod .. " + E", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + minus", hl.dsp.layout("splitratio -0.1"), { repeating = true })
hl.bind(mainMod .. " + equal", hl.dsp.layout("splitratio +0.1"), { repeating = true })

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down", group_aware = true }))

for i = 1, 4 do
	hl.workspace_rule({ workspace = tostring(i), persistent = true })
end
for i = 1, 4 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

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
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind(mainMod .. " + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind(
	mainMod .. " + SHIFT + S",
	hl.dsp.exec_cmd('grim -g "$(slurp)" ~/Pictures/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png')
)
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("~/.config/hypr/scripts/clipmenu.sh"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("~/.config/hypr/scripts/power.sh"))

--- Window rules
hl.window_rule({
	-- Ignore maximize requests from all apps.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

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

hl.window_rule({
	-- Enable tearing and direct scanout in cs2
	match = { class = "cs2" },
	immediate = true,
	fullscreen = true,
})
