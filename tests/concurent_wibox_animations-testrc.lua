-----------------
-- Copyright (C) 2019 Aire-One
--
-- Author : Aire-One (Aire-One@github.com ; Aire-One@gitlab.com)
-----------------

-- require user rc.lua as a base config
-- user rc.lua file should be on a place loaded by awesomewm
require('rc')


local animated_wibox = require 'awesome-AnimationFramework.animated_wibox'
local wibox = require'wibox'


local wib = animated_wibox {
    ontop = true, visible = true, opacity = 1,
    bg = '#fff', -- make the wibox easier to see on the screen
    x = 200,
    y = 50,
    width = 10,
    height = 10
}

local animate = function ()
    wib:play_animation {
        ['width'] = {
            target = { width = 1000 },
            duration = 5
        },
        ['height'] = {
            target = { height = 1000 },
            duration = 5
        }
    }
end

local stop_animation = function ()
    wib:stop_animations('width')
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
button:connect_signal('mouse::leave', stop_animation)
