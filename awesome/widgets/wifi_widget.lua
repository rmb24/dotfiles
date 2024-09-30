-- Imports
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

-- Definir colores
local wifi_connected_color = '#9ece6a' -- Verde (conectado)
local wifi_disconnected_color = '#f7768e' -- Rojo (no conectado o deshabilitado)

-- Íconos
local wifi_icon_connected = "  "
local wifi_icon_disconnected = " 睊 "

-- Crear el widget de WiFi
local wifi_widget = wibox.widget {
    widget = wibox.widget.textbox,
    text = wifi_icon_disconnected
}

-- Crear el tooltip
local wifi_tooltip = awful.tooltip {
    objects = {wifi_widget},
    timeout = 5,
    hover_timeout = 0.5,
    align = "bottom"
}

-- Función para actualizar el estado del WiFi
local function update_wifi_status()
    awful.spawn.easy_async_with_shell("nmcli -t -f WIFI g", function(stdout)
        if stdout:match("enabled") then
            -- Verificar si está conectado a una red
            awful.spawn.easy_async_with_shell("nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d: -f2",
                function(ssid)
                    if ssid ~= "" then
                        wifi_widget.markup = string.format("<span foreground='%s'>%s</span>", wifi_connected_color,
                            wifi_icon_connected)
                        wifi_tooltip.text = "  " .. ssid
                    else
                        wifi_widget.markup = string.format("<span foreground='%s'>%s</span>", wifi_disconnected_color,
                            wifi_icon_disconnected)
                        wifi_tooltip.text = "No conectado"
                    end
                end)
        else
            -- WiFi deshabilitado
            wifi_widget.markup = string.format("<span foreground='%s'>%s</span>", wifi_disconnected_color,
                wifi_icon_disconnected)
            wifi_tooltip.text = "WiFi deshabilitado"
        end
    end)
end

-- Función para abrir el menú de WiFi
local function open_wifi_menu()
    awful.spawn("/home/rmb/.config/awesome/scripts/rofi-wifi-menu.sh")
end

-- Asignar una acción al botón del widget
wifi_widget:buttons(awful.button({}, 1, open_wifi_menu))

-- Actualizar el estado del WiFi inicialmente
update_wifi_status()

-- Temporizador para actualizar el estado periódicamente
local wifi_timer = gears.timer {
    timeout = 10,
    autostart = true,
    callback = update_wifi_status
}

return wifi_widget
