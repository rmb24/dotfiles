-- tags.lua
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local bling = require("bling")
local beautiful = require("beautiful")
local colors = require("utils.colors")

-- Define taglist buttons
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

local function setup_tags(s)
    -- Each screen has its own tag table.
    local pacman_icon = " 󰮯 "
    local ghost_icon = " 󰊠 "
    local dot_icon = "  "

    local tags = {pacman_icon, ghost_icon, ghost_icon, ghost_icon}
    s.tags = awful.tag(tags, s, awful.layout.layouts[1])

    local function update_tag_icons()
        for _, tag in ipairs(s.tags) do
            if tag.selected then
                tag.name = pacman_icon
            elseif #tag:clients() > 0 then
                tag.name = dot_icon
            else
                tag.name = ghost_icon
            end
        end
    end

    math.randomseed(os.time())

    for _, tag in ipairs(s.tags) do
        -- Asigna un color aleatorio a cada etiqueta de fantasma
        if tag.name == ghost_icon then
            tag.color = colors[math.random(#colors)]
        end

        tag:connect_signal("property::selected", update_tag_icons)
        tag:connect_signal("tagged", update_tag_icons)
        tag:connect_signal("untagged", function()
            if #tag:clients() == 0 then
                update_tag_icons()
            end
        end)
    end

    client.connect_signal("untagged", function(c, tag)
        if #tag:clients() == 0 then
            update_tag_icons()
        end
    end)

    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(awful.button({}, 1, function()
        awful.layout.inc(1)
    end), awful.button({}, 3, function()
        awful.layout.inc(-1)
    end), awful.button({}, 4, function()
        awful.layout.inc(1)
    end), awful.button({}, 5, function()
        awful.layout.inc(-1)
    end)))

    bling.widget.tag_preview.enable {
        show_client_content = true, -- Whether or not to show the client content
        x = 10, -- The x-coord of the popup
        y = 10, -- The y-coord of the popup
        scale = 0.25, -- The scale of the previews compared to the screen
        honor_padding = true, -- Honor padding when creating widget size
        honor_workarea = true, -- Honor work area when creating widget size
        placement_fn = function(c) -- Place the widget using awful.placement (this overrides x & y)
            awful.placement.top_left(c, {
                margins = {
                    top = 50,
                    left = 30
                }
            })
        end,
        background_widget = wibox.widget { -- Set a background image (like a wallpaper) for the widget 
            image = beautiful.wallpaper,
            horizontal_fit_policy = "fit",
            vertical_fit_policy = "fit",
            widget = wibox.widget.imagebox
        }
    }

    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
        widget_template = {
            {
                id = 'text_role',
                widget = wibox.widget.textbox
            },
            widget = wibox.container.background,
            id = 'background_role',
            create_callback = function(self, t, index, objects)
                local bg_role = self:get_children_by_id('background_role')[1]
                if t.name == ghost_icon then
                    bg_role.fg = t.color
                else
                    bg_role.fg = nil
                end

                self:connect_signal('mouse::enter', function()
                    -- BLING: Only show widget when there are clients in the tag
                    if #t:clients() > 0 then
                        -- BLING: Update the widget with the new tag
                        awesome.emit_signal("bling::tag_preview::update", t)
                        -- BLING: Show the widget
                        awesome.emit_signal("bling::tag_preview::visibility", s, true)
                    end
                end)

                self:connect_signal('mouse::leave', function()
                    -- BLING: Turn the widget off
                    awesome.emit_signal("bling::tag_preview::visibility", s, false)

                    if self.has_backup then
                        self.bg = self.backup
                    end
                end)
            end,
            update_callback = function(self, t, index, objects)
                local bg_role = self:get_children_by_id('background_role')[1]
                if t.name == dot_icon and #t:clients() == 0 then
                    bg_role.fg = nil
                elseif t.name == ghost_icon then
                    bg_role.fg = t.color
                else
                    bg_role.fg = nil
                end
            end
        }
    }
end

return setup_tags
