local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")

-- Function to generate the calendar for the current month
local function generate_calendar()
    local current_date = os.date("*t") -- Get current date
    local days_in_month = os.date("*t", os.time {
        year = current_date.year,
        month = current_date.month + 1,
        day = 0
    }).day -- Get total days in the month
    local first_day = os.date("*t", os.time {
        year = current_date.year,
        month = current_date.month,
        day = 1
    }).wday -- Get the first weekday of the month (1=Sunday)

    local calendar = "<b>" .. os.date("%B %Y") .. "</b>\n" -- Month and year at the top
    local weekdays = {"Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"} -- Short names of the weekdays
    for _, day in ipairs(weekdays) do
        calendar = calendar .. day .. " " -- Add weekday headers
    end
    calendar = calendar .. "\n"

    local day_counter = 1
    for i = 1, 42 do -- A grid of 6 rows and 7 columns (max days)
        if i >= first_day and day_counter <= days_in_month then
            local day_str = string.format("%2d", day_counter) -- Format day with leading space
            if os.date("%d") == string.format("%02d", day_counter) then
                -- Highlight the current day
                calendar = calendar .. "<b><span foreground='#f7768e'>" .. day_str .. "</span></b> "
            else
                calendar = calendar .. day_str .. " "
            end
            day_counter = day_counter + 1
        else
            calendar = calendar .. "   " -- Empty spaces before the first day and after the last day
        end
        if i % 7 == 0 then
            calendar = calendar .. "\n"
        end
    end

    return calendar
end

-- Create the clock widget with an icon and textclock
local clock_widget = wibox.widget {
    {
        {
            font = "Nerd Font 16", -- Adjust font and size
            markup = "<span foreground='#2ac3de'> 󰃰 </span>", -- Nerd Font icon
            widget = wibox.widget.textbox
        },
        {
            wibox.widget.textclock(), -- Actual clock widget
            widget = wibox.container.margin
        },
        layout = wibox.layout.fixed.horizontal
    },
    widget = wibox.container.background,
    bg = "#1a1b26", -- Background color
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 10) -- Rounded corners
    end
}

-- Create the tooltip and attach it to clock_widget
local clock_tooltip = awful.tooltip {
    objects = {clock_widget}, -- Attach to the clock widget
    mode = "outside",
    align = "right",
    preferred_positions = {"bottom"},
    preferred_alignments = {"middle"},
    margin_leftright = 10,
    margin_topbottom = 10,
    timer_function = function()
        return generate_calendar() -- Dynamic calendar content
    end
}

return clock_widget
