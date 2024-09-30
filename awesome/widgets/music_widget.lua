-- music_widget.lua
local wibox = require("wibox")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local bling = require("bling")
local awful = require("awful")
local lgi = require('lgi')
local GdkPixbuf = lgi.GdkPixbuf
local colors_utils = require("utils.colors_utils")

local function create_text_widget(markup)
    return wibox.widget {
        markup = markup,
        align = 'center',
        valign = 'center',
        widget = wibox.widget.textbox
    }
end

local art = wibox.widget {
    image = "default_image.png",
    resize = true,
    forced_height = dpi(80),
    forced_width = dpi(80),
    widget = wibox.widget.imagebox
}

local name_widget = create_text_widget('No players')
local title_widget = create_text_widget('Nothing Playing')
local artist_widget = create_text_widget('Nothing Playing')
local icon_music = create_text_widget("<span foreground='#7aa2f7'> 󰎇</span>")

local position_widget = create_text_widget('00:00 / 00:00')

local function format_time(seconds)
    local minutes = math.floor(seconds / 60)
    local seconds = math.floor(seconds % 60)
    return string.format("%02d:%02d", minutes, seconds)
end

local playerctl = bling.signal.playerctl.lib()
playerctl:connect_signal("position", function(_, interval_sec, length_sec)
    local position_text = string.format("%s / %s", format_time(interval_sec), format_time(length_sec))
    position_widget:set_markup_silently(position_text)
end)

local function create_button(id, markup, click_action)
    local button = wibox.widget {
        id = id,
        widget = wibox.widget.textbox,
        markup = markup
    }
    button:buttons(gears.table.join(awful.button({}, 1, click_action)))
    return button
end

local prev_button = create_button('prev', "<span foreground='#7aa2f7'> 󰒮 </span>", function()
    playerctl:previous()
end)
local play_button = create_button('play', "<span foreground='#7aa2f7'>  </span>", function()
    playerctl:play_pause()
end)
local next_button = create_button('next', "<span foreground='#7aa2f7'> 󰒭</span>", function()
    playerctl:next()
end)

local music_buttons = wibox.widget {
    {
        {
            prev_button,
            play_button,
            next_button,
            spacing = dpi(20),
            layout = wibox.layout.fixed.horizontal
        },
        margins = dpi(10),
        widget = wibox.container.margin
    },
    widget = wibox.container.background,
    shape = gears.shape.rounded_rect,
    visible = false
}

local music_player = wibox.widget {
    {
        art,
        icon_music,
        {
            {
                name_widget,
                layout = wibox.layout.fixed.vertical
            },
            margins = dpi(10),
            widget = wibox.container.margin
        },
        music_buttons,
        layout = wibox.layout.fixed.horizontal
    },
    widget = wibox.container.background,
    shape = gears.shape.rounded_rect,
    visible = false
}

local margin_size = dpi(10)
local icons = {
    music = "󰎈",
    artist = "󰠃",
    position = "󱫜"
}

-- Función auxiliar para truncar texto y añadir puntos suspensivos
local function truncate_text(text, max_length)
    if #text > max_length then
        return text:sub(1, max_length - 3) .. "..."
    else
        return text
    end
end

local function get_tooltip_content()
    local title = title_widget.text or "Unknown Title"
    local artist = artist_widget.text or "Unknown Artist"
    local position = position_widget.text or "00:00 / 00:00"

    -- Truncar el título si es demasiado largo
    local truncated_title = truncate_text(title, 30) -- Ajusta el valor 30 según sea necesario

    return string.format(
        "<span foreground='#7aa2f7'>%s</span> %s\n<span foreground='#bb9af7'>%s</span> %s\n<span foreground='#9ece6a'>%s</span> %s",
        icons.music, truncated_title, icons.artist, artist, icons.position, position)
end

local music_tooltip = awful.tooltip {
    objects = {music_player},
    mode = 'outside',
    align = 'right',
    preferred_positions = {'bottom'},
    preferred_alignments = {'middle'},
    margins = margin_size,
    timer_function = get_tooltip_content
}

playerctl:connect_signal("no_players", function()
    music_player.visible = false
    music_buttons.visible = false
end)
local current_text_color = "#FFFFFF"
local function update_text_color(dominant_color)
    local luminance = colors_utils.get_luminance(dominant_color)
    current_text_color = luminance > 0.5 and "#000000" or "#FFFFFF"

    -- Actualiza solo el color sin cambiar el contenido
    name_widget:set_markup_silently(string.format("<span foreground='%s'>%s</span>", current_text_color,
        name_widget.text))
    title_widget:set_markup_silently(string.format("<span foreground='%s'>%s</span>", current_text_color,
        title_widget.text))
    artist_widget:set_markup_silently(string.format("<span foreground='%s'>%s</span>", current_text_color,
        artist_widget.text))
    icon_music:set_markup_silently(string.format("<span foreground='%s'> 󰎇</span>", current_text_color))
    position_widget:set_markup_silently(string.format("<span foreground='%s'>%s</span>", current_text_color,
        position_widget.text))
    prev_button:set_markup(string.format("<span foreground='%s'> 󰒮 </span>", current_text_color))
    next_button:set_markup(string.format("<span foreground='%s'> 󰒭</span>", current_text_color))

    local current_icon = play_button.text:match("") and "" or ""
    play_button:set_markup(string.format("<span foreground='%s'> %s </span>", current_text_color, current_icon))
end

local function update_play_button(playing)
    local icon = playing and "" or ""
    play_button:set_markup(string.format("<span foreground='%s'> %s </span>", current_text_color, icon))
end

playerctl:connect_signal("playback_status", function(_, playing)
    update_play_button(playing)
end)

playerctl:connect_signal("ready", function()
    update_play_button(playerctl.is_playing)
end)

playerctl:connect_signal("metadata", function(_, title, artist, album_path, album, new, player_name)
    if player_name and title and artist then
        music_player.visible = true
        music_buttons.visible = true
    else
        music_player.visible = false
        music_buttons.visible = false
    end
    art:set_image(gears.surface.load_uncached(album_path))
    local dominant_color = colors_utils.get_dominant_color(album_path)
    music_player.bg = dominant_color
    -- Recreate the tooltip with the new background color
    music_tooltip.bg = dominant_color
    music_buttons.bg = dominant_color
    name_widget:set_markup_silently(player_name)
    title_widget:set_markup_silently(title)
    artist_widget:set_markup_silently(artist)

    update_text_color(dominant_color)
end)

return {
    music_player = music_player,
    music_buttons = music_buttons,
    position_widget = position_widget
}
