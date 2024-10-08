-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")

local dpi = xresources.apply_dpi

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
-- awful.spawn.with_shell("polybar")
awful.spawn.with_shell("picom &")
awful.spawn.with_shell("nitrogen --restore")
-- awful.spawn.with_shell("nm-applet &")
-- awful.spawn.with_shell("blueman-applet")
-- Import module:
local battery_widget = require("modules/battery-widget")
local layout_indicator = require("modules/keyboard-layout-indicator")
local volume_control = require("modules/volume-control")
local brightness_widget = require("awesome-wm-widgets.brightness-widget.brightness")
local volume_widget = require('awesome-wm-widgets.volume-widget.volume')
local bling = require("bling")
-- local screenshot = require("modules/screenshot")

volumecfg = volume_control({
    device = nil, -- e.g.: "default", "pulse"
    cardid = nil, -- e.g.: 0, 1, ...
    channel = "Master",
    step = '5%', -- step size for up/down
    lclick = "toggle", -- mouse actions described below
    mclick = "pavucontrol",
    rclick = "pavucontrol",
    listen = false, -- enable/disable listening for audio status changes
    widget = nil, -- use this instead of creating a awful.widget.textbox
    font = 'Iovseka Nerd Font Bold 14', -- font used for the widget's text
    callback = nil, -- called to update the widget: `callback(self, state)`
    widget_text = {
        on = '% 3d%% ', -- three digits, fill with leading spaces
        off = '% 3dM '
    },
    tooltip = "Volume: ${volume}%"
})

local function notification_play_soud()
    awful.spawn.with_shell("paplay /home/rmb/.config/awesome/sound.mp3")

end

-- Notification Settings 
naughty.config.spacing = 10
naughty.config.padding = 10
naughty.config.defaults.timeout = 5
naughty.config.defaults.screen = 1
naughty.config.defaults.position = "top_right"
naughty.config.defaults.margin = 16
naughty.config.defaults.border_width = 0
naughty.config.defaults.ontop = true
naughty.config.defaults.font = "Iosevka Nerd Font Bold 16"
naughty.config.defaults.icon_size = 64
naughty.config.defaults.shape = gears.shape.rounded_rect

-- Notification Sound

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then
            return
        end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {awful.layout.suit.tile.left, awful.layout.suit.spiral, awful.layout.suit.floating,
                        awful.layout.suit.tile, awful.layout.suit.tile.bottom, awful.layout.suit.tile.top,
                        awful.layout.suit.fair, awful.layout.suit.fair.horizontal, awful.layout.suit.spiral.dwindle,
                        awful.layout.suit.max, awful.layout.suit.max.fullscreen, awful.layout.suit.magnifier,
                        awful.layout.suit.corner.nw -- awful.layout.suit.corner.ne,
-- awful.layout.suit.corner.sw,
-- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {{"hotkeys", function()
    hotkeys_popup.show_help(nil, awful.screen.focused())
end}, {"manual", terminal .. " -e man awesome"}, {"edit config", editor_cmd .. " " .. awesome.conffile},
                 {"restart", awesome.restart}, {"quit", function()
    awesome.quit()
end}}

mymainmenu = awful.menu({
    items = {{"awesome", myawesomemenu, beautiful.awesome_icon}, {"open terminal", terminal}}
})

mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
-- mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(awful.button({}, 1, function(t)
    t:view_only()
end), awful.button({modkey}, 1, function(t)
    if client.focus then
        client.focus:move_to_tag(t)
    end
end), awful.button({}, 3, awful.tag.viewtoggle), awful.button({modkey}, 3, function(t)
    if client.focus then
        client.focus:toggle_tag(t)
    end
end), awful.button({}, 4, function(t)
    awful.tag.viewnext(t.screen)
end), awful.button({}, 5, function(t)
    awful.tag.viewprev(t.screen)
end))

local tasklist_buttons = gears.table.join(awful.button({}, 1, function(c)
    if c == client.focus then
        c.minimized = true
    else
        c:emit_signal("request::activate", "tasklist", {
            raise = true
        })
    end
end), awful.button({}, 3, function()
    awful.menu.client_list({
        theme = {
            width = 250
        }
    })
end), awful.button({}, 4, function()
    awful.client.focus.byidx(1)
end), awful.button({}, 5, function()
    awful.client.focus.byidx(-1)
end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end
kbdcfg = layout_indicator({
    layouts = {{
        name = "us",
        layout = "us",
        variant = nil
    }, {
        name = "latam",
        layout = "latam",
        variant = nil
    }},
    -- optionally, specify commands to be executed after changing layout:
    post_set_hooks = {"xmodmap ~/.Xmodmap", "setxkbmap -option caps:escape"}
})

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)
local setup_tags = require("widgets.tags")
local widgets = require("widgets")
awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    setup_tags(s)

    -- -- Create a tasklist widget
    -- s.mytasklist = awful.widget.tasklist {
    --     screen = s,
    --     filter = awful.widget.tasklist.filter.currenttags,
    --     buttons = tasklist_buttons
    -- }

    -- Define custom shapes
    local function custom_shape(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, RADIUS)
    end

    local function rounded_background(widget, bg_color, radius)
        return wibox.widget {
            {
                widget,
                widget = wibox.container.background,
                bg = bg_color,
                shape = function(cr, width, height)
                    gears.shape.rounded_rect(cr, width, height, radius)
                end
            },
            widget = wibox.container.margin
        }
    end

    -- Create the wibox
    s.mywibox = awful.wibar({
        border_width = 2,
        position = "top",
        screen = s,
        shape = custom_shape,
        bg = "#00000000"
    })

    -- Separators
    local tbox_separator = wibox.widget.textbox(" | ")
    local l_sep = wibox.widget.textbox(" [ ")
    local m_sep = wibox.widget.textbox(" ][ ")
    local r_sep = wibox.widget.textbox(" ] ")

    -- Systray widget 
    local systray = wibox.widget.systray()
    systray:set_base_size(24)

    -- Envolver el systray en un contenedor para centrarlo verticalmente
    local systray_container = wibox.container.place(systray, "center", "center")

    -- Left container
    local left_container = rounded_background({
        layout = wibox.layout.fixed.horizontal,
        l_sep,
        s.mytaglist,
        r_sep,
        widgets.music_widget.music_player
    }, "#1a1b26", 10)

    -- Right container
    local right_container = rounded_background({
        layout = wibox.layout.fixed.horizontal,
        widgets.clock_widget,
        l_sep,
        kbdcfg,
        tbox_separator,
        brightness_widget {
            type = 'icon_and_text',
            program = 'brightnessctl',
            step = 2,
            percentage = true,
            tooltip = true
        },
        tbox_separator,
        volumecfg,
        tbox_separator,
        systray_container, -- Usar el contenedor centrado
        widgets.wifi_widget,
        widgets.bluetooth_widget,
        tbox_separator,
        battery_widget {
            ac = "AC",
            adapter = "BAT1",
            percent_colors = {{25, "red"}, {50, "orange"}, {999, "green"}},
            listen = true,
            timeout = 10,
            widget_text = "${AC_BAT}${color_on}${percent}%${color_off}",
            widget_font = "Iosevka Nerd Font Bold 16",
            tooltip_text = "Battery ${state}${time_est}\nCapacity: ${capacity_percent}%",
            alert_threshold = 5,
            alert_timeout = 0,
            alert_title = "Low battery !",
            alert_text = "${AC_BAT}${time_est}",
            alert_icon = "themes/battery-low.svg",
            warn_full_battery = true,
            ac_prefix = {{25, "󰢜  "}, {50, "󰢝  "}, {75, "󰢞  "}, {95, "󰂋  "}, {100, "󰂅  "}},
            battery_prefix = {{25, "  "}, {50, "  "}, {75, "  "}, {100, "  "}}
        },
        tbox_separator,
        widgets.power_widget,
        r_sep
    }, "#1a1b26", 10)

    -- Setup wibox
    s.mywibox:setup{
        layout = wibox.layout.align.horizontal,
        left_container,
        middle_container,
        right_container
    }

end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(awful.button({}, 3, function()
    mymainmenu:toggle()
end), awful.button({}, 4, awful.tag.viewnext), awful.button({}, 5, awful.tag.viewprev)))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(awful.key({modkey}, "Shift_R", function()
    kbdcfg:next()
end), awful.key({modkey, "Shift"}, "Shift_R", function()
    kbdcfg:prev()
end), awful.key({}, "XF86AudioRaiseVolume", function()
    volumecfg:up()
end), awful.key({}, "XF86AudioLowerVolume", function()
    volumecfg:down()
end), awful.key({}, "XF86AudioMute", function()
    volumecfg:toggle()
end), awful.key({}, "XF86MonBrightnessDown", function()
    brightness_widget:dec()
end), awful.key({}, "XF86MonBrightnessUp", function()
    brightness_widget:inc()
end), awful.key({modkey}, "s", hotkeys_popup.show_help, {
    description = "show help",
    group = "awesome"
}), awful.key({modkey}, "Left", awful.tag.viewprev, {
    description = "view previous",
    group = "tag"
}), awful.key({modkey}, "Right", awful.tag.viewnext, {
    description = "view next",
    group = "tag"
}), awful.key({modkey}, "Escape", awful.tag.history.restore, {
    description = "go back",
    group = "tag"
}), awful.key({modkey}, "j", function()
    awful.client.focus.byidx(1)
end, {
    description = "focus next by index",
    group = "client"
}), awful.key({modkey}, "k", function()
    awful.client.focus.byidx(-1)
end, {
    description = "focus previous by index",
    group = "client"
}), -- awful.key({modkey}, "w", function()
--     mymainmenu:show()
-- end, {
--     description = "show main menu",
--     group = "awesome"
-- }), -- Layout manipulation
awful.key({modkey, "Shift"}, "j", function()
    awful.client.swap.byidx(1)
end, {
    description = "swap with next client by index",
    group = "client"
}), awful.key({modkey, "Shift"}, "k", function()
    awful.client.swap.byidx(-1)
end, {
    description = "swap with previous client by index",
    group = "client"
}), awful.key({modkey, "Control"}, "j", function()
    awful.screen.focus_relative(1)
end, {
    description = "focus the next screen",
    group = "screen"
}), awful.key({modkey, "Control"}, "k", function()
    awful.screen.focus_relative(-1)
end, {
    description = "focus the previous screen",
    group = "screen"
}), awful.key({modkey}, "u", awful.client.urgent.jumpto, {
    description = "jump to urgent client",
    group = "client"
}), awful.key({modkey}, "Tab", function()
    awful.client.focus.history.previous()
    if client.focus then
        client.focus:raise()
    end
end, {
    description = "go back",
    group = "client"
}), -- Standard program
awful.key({modkey}, "Return", function()
    awful.spawn(terminal)
end, {
    description = "open a terminal",
    group = "launcher"
}), awful.key({modkey, "Control"}, "r", awesome.restart, {
    description = "reload awesome",
    group = "awesome"
}), awful.key({modkey, "Shift"}, "q", awesome.quit, {
    description = "quit awesome",
    group = "awesome"
}), awful.key({modkey}, "l", function()
    awful.tag.incmwfact(0.05)
end, {
    description = "increase master width factor",
    group = "layout"
}), awful.key({modkey}, "h", function()
    awful.tag.incmwfact(-0.05)
end, {
    description = "decrease master width factor",
    group = "layout"
}), awful.key({modkey, "Shift"}, "h", function()
    awful.tag.incnmaster(1, nil, true)
end, {
    description = "increase the number of master clients",
    group = "layout"
}), awful.key({modkey, "Shift"}, "l", function()
    awful.tag.incnmaster(-1, nil, true)
end, {
    description = "decrease the number of master clients",
    group = "layout"
}), awful.key({modkey, "Control"}, "h", function()
    awful.tag.incncol(1, nil, true)
end, {
    description = "increase the number of columns",
    group = "layout"
}), awful.key({modkey, "Control"}, "l", function()
    awful.tag.incncol(-1, nil, true)
end, {
    description = "decrease the number of columns",
    group = "layout"
}), awful.key({modkey}, "space", function()
    awful.layout.inc(1)
end, {
    description = "select next",
    group = "layout"
}), awful.key({modkey, "Shift"}, "space", function()
    awful.layout.inc(-1)
end, {
    description = "select previous",
    group = "layout"
}), awful.key({modkey, "Control"}, "n", function()
    local c = awful.client.restore()
    -- Focus restored client
    if c then
        c:emit_signal("request::activate", "key.unminimize", {
            raise = true
        })
    end
end, {
    description = "restore minimized",
    group = "client"
}), -- Toggle notifications
awful.key({modkey, "Control"}, "n", function()
    naughty.suspend()
end, {
    description = "toggle notifications",
    group = "awesome"
}), -- Show notifications
awful.key({modkey, "Control"}, "m", function()
end, {
    description = "show notifications",
    group = "awesome"
}), -- Prompt
awful.key({modkey}, "Print", function()
    awful.spawn.with_shell("scrot -z ~/Pictures/ScreenShots/%Y-%m-%d-capture.png")
end, {
    description = "screenshot",
    group = "launcher"
}), awful.key({modkey, "Control"}, "l", function()
    awful.spawn("/home/rmb/.config/awesome/scripts/lock.sh")
end), awful.key({modkey}, "e", function()
    awful.spawn.with_shell("thunar")
end), awful.key({modkey}, "r", function()
    awful.spawn.with_shell("rofi -show drun -show-icons &>> /tmp/rofi.log")
end), awful.key({modkey}, "b", function()
    awful.spawn.with_shell("rofi-bluetooth -show-icons &")
end), awful.key({modkey}, "p", function()
    awful.spawn.with_shell("rofi -show power-menu -modi power-menu:rofi-power-menu")
end), awful.key({modkey}, "x", function()
    awful.prompt.run {
        prompt = "Run Lua code: ",
        textbox = awful.screen.focused().mypromptbox.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. "/history_eval"
    }
end, {
    description = "lua execute prompt",
    group = "awesome"
}) -- Menubar
-- awful.key({modkey}, "p", function()
--     menubar.show()
-- end, {
--     description = "show the menubar",
--     group = "launcher"
-- })
)

clientkeys = gears.table.join(awful.key({modkey}, "f", function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
end, {
    description = "toggle fullscreen",
    group = "client"
}), awful.key({modkey, "Shift"}, "c", function(c)
    c:kill()
end, {
    description = "close",
    group = "client"
}), awful.key({modkey, "Control"}, "space", awful.client.floating.toggle, {
    description = "toggle floating",
    group = "client"
}), awful.key({modkey, "Control"}, "Return", function(c)
    c:swap(awful.client.getmaster())
end, {
    description = "move to master",
    group = "client"
}), awful.key({modkey}, "o", function(c)
    c:move_to_screen()
end, {
    description = "move to screen",
    group = "client"
}), awful.key({modkey}, "t", function(c)
    c.ontop = not c.ontop
end, {
    description = "toggle keep on top",
    group = "client"
}), awful.key({modkey}, "n", function(c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
end, {
    description = "minimize",
    group = "client"
}), awful.key({modkey}, "m", function(c)
    c.maximized = not c.maximized
    c:raise()
end, {
    description = "(un)maximize",
    group = "client"
}), awful.key({modkey, "Control"}, "m", function(c)
    c.maximized_vertical = not c.maximized_vertical
    c:raise()
end, {
    description = "(un)maximize vertically",
    group = "client"
}), awful.key({modkey, "Shift"}, "m", function(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c:raise()
end, {
    description = "(un)maximize horizontally",
    group = "client"
}))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys, -- View tag only.
    awful.key({modkey}, "#" .. i + 9, function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
            tag:view_only()
        end
    end, {
        description = "view tag #" .. i,
        group = "tag"
    }), -- Toggle tag display.
    awful.key({modkey, "Control"}, "#" .. i + 9, function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
            awful.tag.viewtoggle(tag)
        end
    end, {
        description = "toggle tag #" .. i,
        group = "tag"
    }), -- Move client to tag.
    awful.key({modkey, "Shift"}, "#" .. i + 9, function()
        if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then
                client.focus:move_to_tag(tag)
            end
        end
    end, {
        description = "move focused client to tag #" .. i,
        group = "tag"
    }), -- Toggle tag on focused client.
    awful.key({modkey, "Control", "Shift"}, "#" .. i + 9, function()
        if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then
                client.focus:toggle_tag(tag)
            end
        end
    end, {
        description = "toggle focused client on tag #" .. i,
        group = "tag"
    }))
end

clientbuttons = gears.table.join(awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {
        raise = true
    })
end), awful.button({modkey}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {
        raise = true
    })
    awful.mouse.client.move(c)
end), awful.button({modkey}, 3, function(c)
    c:emit_signal("request::activate", "mouse_click", {
        raise = true
    })
    awful.mouse.client.resize(c)
end))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = { -- All clients will match this rule.
{
    rule = {},
    properties = {
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        raise = true,
        keys = clientkeys,
        buttons = clientbuttons,
        screen = awful.screen.preferred,
        placement = awful.placement.no_overlap + awful.placement.no_offscreen
    }
}, -- Floating clients.
{
    rule_any = {
        instance = {"DTA", -- Firefox addon DownThemAll.
        "copyq", -- Includes session name in class.
        "pinentry"},
        class = {"Arandr", "Blueman-manager", "Gpick", "Kruler", "MessageWin", -- kalarm.
        "Sxiv", "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
        "Wpa_gui", "veromix", "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {"Event Tester" -- xev.
        },
        role = {"AlarmWindow", -- Thunderbird's calendar.
        "ConfigManager", -- Thunderbird's about:config.
        "pop-up" -- e.g. Google Chrome's (detached) Developer Tools.
        }
    },
    properties = {
        floating = true
    }
}, -- Add titlebars to normal clients and dialogs
{
    rule_any = {
        type = {"normal", "dialog"}
    },
    properties = {
        titlebars_enabled = true
    }
} -- Set Firefox to always map on the tag named "2" on screen 1.
-- { rule = { class = "Firefox" },
--   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(awful.button({}, 1, function()
        c:emit_signal("request::activate", "titlebar", {
            raise = true
        })
        awful.mouse.client.move(c)
    end), awful.button({}, 3, function()
        c:emit_signal("request::activate", "titlebar", {
            raise = true
        })
        awful.mouse.client.resize(c)
    end))

    -- awful.titlebar(c):setup{
    --     { -- Left
    --         awful.titlebar.widget.iconwidget(c),
    --         buttons = buttons,
    --         layout = wibox.layout.fixed.horizontal
    --     },
    --     { -- Middle
    --         { -- Title
    --             align = "center",
    --             widget = awful.titlebar.widget.titlewidget(c)
    --         },
    --         buttons = buttons,
    --         layout = wibox.layout.flex.horizontal
    --     },
    --     { -- Right
    --         awful.titlebar.widget.floatingbutton(c),
    --         awful.titlebar.widget.maximizedbutton(c),
    --         awful.titlebar.widget.stickybutton(c),
    --         awful.titlebar.widget.ontopbutton(c),
    --         awful.titlebar.widget.closebutton(c),
    --         layout = wibox.layout.fixed.horizontal()
    --     },
    --     layout = wibox.layout.align.horizontal
    -- }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {
        raise = false
    })
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
    c.opacity = 1
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
    c.opacity = 0.7
end)
-- }}}

