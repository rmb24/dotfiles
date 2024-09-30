-- Cargar librerías
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

-- Bluetooth widget
local bluetooth_widget = wibox.widget {
    widget = wibox.widget.textbox,
    text = " 󰂯 "
}

-- Crear el tooltip
local bluetooth_tooltip = awful.tooltip {
    objects = {bluetooth_widget},
    timeout = 5,
    hover_timeout = 0.5,
    align = "bottom"
}

-- Asignar una acción al botón del widget para abrir rofi-bluetooth
bluetooth_widget:buttons(awful.button({}, 1, function()
    awful.spawn.with_shell("rofi-bluetooth &")
end))

-- Función para actualizar el icono del Bluetooth
local function set_bluetooth_icon(color)
    bluetooth_widget.markup = string.format("<span foreground='%s'> 󰂯 </span>", color)
end

-- Función para actualizar el estado del Bluetooth
local function update_bluetooth_status()
    awful.spawn.easy_async_with_shell([[
        bluetoothctl show | grep 'Powered: yes' && bluetoothctl devices Connected
    ]], function(stdout)
        if stdout:match("Powered: yes") then
            local device_mac = stdout:match("Device (%S+)")
            if device_mac then
                awful.spawn.easy_async_with_shell("bluetoothctl info " .. device_mac .. " | grep 'Name'",
                    function(name_stdout)
                        local device_name = name_stdout:match("Name: (.+)")
                        set_bluetooth_icon('#7aa2f7') -- Icono azul cuando hay un dispositivo conectado
                        bluetooth_tooltip.text =
                            device_name and " " .. device_name or "No hay dispositivos conectados"
                    end)
            else
                set_bluetooth_icon('#ffffff') -- Icono blanco cuando no hay dispositivos conectados
                bluetooth_tooltip.text = "No hay dispositivos conectados"
            end
        else
            set_bluetooth_icon('#f7768e') -- Icono rojo cuando el Bluetooth está apagado
            bluetooth_tooltip.text = "Bluetooth apagado"
        end
    end)
end

-- Llama a update_bluetooth_status al inicio para establecer el estado inicial
update_bluetooth_status()

-- Configurar un temporizador para actualizar el estado periódicamente
gears.timer {
    timeout = 10, -- Intervalo de actualización de 30 segundos
    autostart = true,
    callback = update_bluetooth_status
}

return bluetooth_widget
