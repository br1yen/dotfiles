---@diagnostic disable: undefined-global

hl.monitor({ output = "DP-3", mode = "1920x1080@180.00Hz", cm = "srgb", bitdepth = 8 })
hl.monitor({ output = "eDP-1", mode = "1920x1080@60.01Hz", scale = 1.0 })

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("ghostty --gtk-single-instance=true --initial-window=false")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaybg -i ~/Sync/Pictures/mellifluous4.jpg")
    hl.exec_cmd("hypridle")
end)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Hackneyed-Dark")
hl.env("HYPRCURSOR_THEME", "Hackneyed-Dark")

hl.config({
    general = {
        gaps_out = 50,
        gaps_in = 0,
        border_size = 10,
        col = {
            active_border = "#00000040",
            inactive_border = "#00000020",
        },
        allow_tearing = true,
        layout = "scrolling",
        resize_on_border = true,
        no_focus_fallback = false,
    },

    dwindle = {
        preserve_split = true,
    },

    scrolling = {
        fullscreen_on_one_column = false,
        explicit_column_widths = "0.5, 1.0",
        follow_min_visible = 1.0
    },

    render = {
        direct_scanout = 2,
        cm_auto_hdr = 0,
    },

    decoration = {
        rounding = 0,
        rounding_power = 1,

        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = false,
            color = "0x80000000",
            color_inactive = "0x40000000",
            offset = { 0, 2 },
            range = 4,
            render_power = 3,
            scale = 1.03,
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
            stacked = true,
            font_family = "Lilex Nerd Font Mono Medium",
            font_size = 14,
            gaps_in = 0,
            gaps_out = 1,
            indicator_height = 0,
            text_color = "0xffffffff",
            text_color_inactive = "0xff5b5b5b",
        },
        col = {
            border_active = "#00000040",
            border_inactive = "#00000020",
            border_locked_active = "#00000040",
            border_locked_inactive = "#00000020",
        },
    },

    binds = {
        movefocus_cycles_groupfirst = false,
        drag_threshold = 10,
        window_direction_monitor_fallback = false,
    },

    cursor = {
        no_warps = false,
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
        repeat_rate = 40,
        repeat_delay = 300,

        sensitivity = 0,
        accel_profile = "flat",

        follow_mouse = 1,

        touchpad = {
            natural_scroll = false,
        },
    },
})

--- Keybinds
local mainMod = "ALT"

hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("~/.config/hypr/scripts/wmenu.sh"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("ghostty +new-window -e yazi"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("helium-browser"))
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("ghostty +new-window"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())

hl.bind(mainMod .. " + C", hl.dsp.layout("center"))
hl.bind(mainMod .. " + N", function()
    hl.dispatch(hl.dsp.layout("focus r"))
    hl.dispatch(hl.dsp.layout("focus l"))
end)
hl.bind(mainMod .. " + P", function()
    hl.dispatch(hl.dsp.layout("focus l"))
    hl.dispatch(hl.dsp.layout("focus r"))
end)

local function has_neighbor(dir, back)
    local before = hl.get_active_window()
    hl.dispatch(hl.dsp.layout("focus " .. dir))
    local after = hl.get_active_window()
    local moved = after ~= nil and before ~= nil and after ~= before
    if moved then hl.dispatch(hl.dsp.layout("focus " .. back)) end
    return moved
end

hl.bind(mainMod .. " + R", function()
    local wrap = hl.get_config("scrolling.wrap_focus")
    hl.config({ scrolling = { wrap_focus = false } })
    local left  = has_neighbor("l", "r")
    local right = has_neighbor("r", "l")
    hl.config({ scrolling = { wrap_focus = wrap } })

    hl.dispatch(hl.dsp.layout("colresize +conf"))
    if left and right then
        hl.dispatch(hl.dsp.layout("center"))
    elseif left then
        hl.dispatch(hl.dsp.layout("focus l"))
        hl.dispatch(hl.dsp.layout("focus r"))
    else
        hl.dispatch(hl.dsp.layout("fit_into_view"))
    end
end)

local function group_position(window)
    local group = window.group
    if not group or not group.members then
        return nil
    end
    local count = 0
    local pos
    for i, member in ipairs(group.members) do
        count = i
        if member.address == window.address then
            pos = i
        end
    end
    if count < 2 then
        return nil
    end
    return pos, count
end

local function focus_tab_first(direction)
    return function()
        local window = hl.get_active_window()
        if not window then
            return
        end
        local pos, count = group_position(window)
        local forward = direction == "down"
        local at_edge = (forward and pos == count) or (not forward and pos == 1)

        if pos and not at_edge then
            hl.dispatch(forward and hl.dsp.group.next() or hl.dsp.group.prev())
        else
            hl.dispatch(hl.dsp.focus({ direction = direction }))
            hl.dispatch(hl.dsp.window.bring_to_top())
        end
    end
end

hl.bind(mainMod .. " + H", hl.dsp.layout("focus l"))
hl.bind(mainMod .. " + L", hl.dsp.layout("focus r"))
hl.bind(mainMod .. " + J", focus_tab_first("down"))
hl.bind(mainMod .. " + K", focus_tab_first("up"))

local function spit_out(direction)
    return function()
        local window = hl.get_active_window()
        if not window then
            return
        end
        if group_position(window) then
            hl.dispatch(hl.dsp.window.move({ out_of_group = true }))
            hl.dispatch(hl.dsp.layout("promote"))
            if direction == "left" then
                hl.dispatch(hl.dsp.layout("swapcol l"))
            end
        else
            hl.dispatch(hl.dsp.window.move({ direction = direction, group_aware = true }))
        end
    end
end

local function reorder_in_group(direction)
    return function()
        local window = hl.get_active_window()
        if not window then
            return
        end
        local pos, count = group_position(window)
        local forward = direction == "down"
        if pos then
            local at_edge = (forward and pos == count) or (not forward and pos == 1)
            if not at_edge then
                hl.dispatch(hl.dsp.group.move_window({ forward = forward }))
            end
        else
            hl.dispatch(hl.dsp.window.move({ direction = direction }))
        end
    end
end

hl.bind(mainMod .. " + SHIFT + H", spit_out("left"))
hl.bind(mainMod .. " + SHIFT + L", spit_out("right"))
hl.bind(mainMod .. " + SHIFT + J", reorder_in_group("down"))
hl.bind(mainMod .. " + SHIFT + K", reorder_in_group("up"))

hl.bind(mainMod .. " + W", hl.dsp.group.toggle())

hl.bind("SUPER + space", function()
    local window = hl.get_active_window()
    if not window then
        return
    end
    hl.dispatch(hl.dsp.window.cycle_next({
        floating = not window.floating,
        tiled = window.floating,
    }))
end, { description = "Switch focus between tiled and floating windows" })

hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))

for i = 1, 3 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })
end
for i = 1, 3 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + ALT_L", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + CTRL_L", hl.dsp.window.resize(), { mouse = true })

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
hl.bind(mainMod .. " + SHIFT + S",
    hl.dsp.exec_cmd('grim -g "$(slurp)" ~/Pictures/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png'))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("~/.config/hypr/scripts/clipmenu.sh"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("~/.config/hypr/scripts/fzfpdf.sh"))
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
    match = { class = "cs2" },
    immediate = true,
    fullscreen = true,
})

hl.window_rule({
    match = { class = "gamescope" },
    immediate = true,
    fullscreen = true,
})
