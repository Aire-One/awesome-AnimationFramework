-----------------
-- Copyright (C) 2019 Aire-One
--
-- Author : Aire-One (Aire-One@github.com ; Aire-One@gitlab.com)
-----------------

-- require user rc.lua as a base config
-- user rc.lua file should be on a place loaded by awesomewm
require('rc')


local animated_wibox = require 'awesome-AnimationFramework.animated_wibox'
local awful = require'awful'
local gears = require'gears'
local gshape = gears.shape
local wibox = require'wibox'


local screen = awful.screen.focused()
local screen_right = screen.geometry.x + screen.geometry.width


local bubble_size = 10

local message_width = 350
local message_height = 150

local initial_x = screen_right - 30
local initial_y = -bubble_size

local message_x = screen_right - (message_width + 25)
local message_y = 15 + 25 -- bar + gap

local wib = animated_wibox {
    ontop = true, visible = true, opacity = 1,
    bg = '#fff', -- make the wibox easier to see on the screen
    x = initial_x,
    y = initial_y,
    width = bubble_size,
    height = bubble_size,
    shape = function(cr, width, height)
        if (width - height) < 20 then
            gshape.circle(cr, width, height)
        else
            gshape.rounded_rect(cr, width, height, 4)
        end
    end
}

local motion_show = function ()
    local bubble_x_movement_motion_time = 0.2
    local bubble_y_movement_motion_time = 0.15
    local expend_motion_delay = 0.15
    local expend_motion_time = 0.25

    return {
        -- Bubble Movement motion
        {
            target = { x = message_x + message_width/2 },
            easing = 'inOutCirc',
            duration = bubble_x_movement_motion_time
        },
        {
            target = { y = message_y + message_height/2 },
            easing = 'inOutCirc',
            duration = bubble_y_movement_motion_time
        },
        -- Shape & Size motion
        {
            target = {
                x = message_x, y = message_y,
                width = message_width, height = message_height
            },
            easing = 'inOutCubic',
            duration = expend_motion_time,
            delay = expend_motion_delay
        }
    }
end

local motion_hide = function ()
    local bubble_x_movement_motion_time = 0.15
    local bubble_y_movement_motion_time = 0.2
    local collaps_motion_time = 0.25

    return {
        -- Shape & Size motion
        {
            target = { width = bubble_size, height = bubble_size },
            easing = 'inOutCubic',
            duration = collaps_motion_time
        },
        -- Movement motion
        {
            target = { x = initial_x },
            easing = 'inOutCirc',
            duration = bubble_x_movement_motion_time
        },
        {
            target = { y = initial_y },
            easing = 'inOutCirc',
            duration = bubble_y_movement_motion_time
        }
    }
end

local shown = false
local animate = function ()
    wib:play_animation( shown and motion_hide() or motion_show() )
    shown = not shown
end


-- Button to trigger the animated_wibox
local button = wibox {
    ontop = true,
    visible = true,
    opacity = 1,
    x = 50,
    y = 500,
    width = 100,
    height = 50
}
button:connect_signal('mouse::enter', animate)
button:connect_signal('mouse::leave', animate)
