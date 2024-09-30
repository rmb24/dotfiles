-- color_utils.lua
local lgi = require('lgi')
local GdkPixbuf = lgi.GdkPixbuf

local function get_dominant_color(image_path)
    local pixbuf = GdkPixbuf.Pixbuf.new_from_file(image_path)
    if not pixbuf then
        return "#000000"
    end

    local width, height = pixbuf:get_width(), pixbuf:get_height()
    local n_channels = pixbuf:get_n_channels()
    local has_alpha = pixbuf:get_has_alpha() and 1 or 0

    if n_channels < 3 then
        return "#000000"
    end

    local pixel_data = pixbuf:get_pixels()
    local stride = pixbuf:get_rowstride()

    local r_total, g_total, b_total, count = 0, 0, 0, 0

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local offset = y * stride + x * n_channels

            local r = string.byte(pixel_data, offset + 1)
            local g = string.byte(pixel_data, offset + 2)
            local b = string.byte(pixel_data, offset + 3)

            r_total = r_total + r
            g_total = g_total + g
            b_total = b_total + b
            count = count + 1
        end
    end

    local r_avg = math.floor(r_total / count)
    local g_avg = math.floor(g_total / count)
    local b_avg = math.floor(b_total / count)

    return string.format("#%02X%02X%02X", r_avg, g_avg, b_avg)
end

local function get_luminance(hex_color)
    local r = tonumber(string.sub(hex_color, 2, 3), 16) / 255
    local g = tonumber(string.sub(hex_color, 4, 5), 16) / 255
    local b = tonumber(string.sub(hex_color, 6, 7), 16) / 255

    local function gamma_correct(c)
        if c <= 0.03928 then
            return c / 12.92
        else
            return ((c + 0.055) / 1.055) ^ 2.4
        end
    end

    local r_corr = gamma_correct(r)
    local g_corr = gamma_correct(g)
    local b_corr = gamma_correct(b)

    return 0.2126 * r_corr + 0.7152 * g_corr + 0.0722 * b_corr
end

return {
    get_dominant_color = get_dominant_color,
    get_luminance = get_luminance
}
