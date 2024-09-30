-- widgets/init.lua
local music_widget = require("widgets.music_widget")
local wifi_widget = require("widgets.wifi_widget")
local bluetooth_widget = require("widgets.bluetooth_widget")
local power_widget = require("widgets.power_widget")
local tags = require("widgets.tags")
local clock_widget = require("widgets.clock_widget")

return {
    music_widget = music_widget,
    wifi_widget = wifi_widget,
    bluetooth_widget = bluetooth_widget,
    power_widget = power_widget,
    tags = tags,
    clock_widget = clock_widget
}
