-- Imports
local wibox = require("wibox")
local awful = require("awful")

-- Ícono del widget
local power_icon = " 󰐥 "

-- Power menu widget
local power_widget = wibox.widget {
    widget = wibox.widget.textbox,
    text = power_icon
}

-- Función para abrir el menú de energía
local function open_power_menu()
    awful.spawn.with_shell("rofi -show power-menu -modi power-menu:rofi-power-menu")
end

-- Asignar acción al hacer clic en el widget
power_widget:buttons(awful.button({}, 1, open_power_menu))

return power_widget
