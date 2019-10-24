-----------------
-- Copyright (C) 2019 Aire-One
--
-- Author : Aire-One (Aire-One@github.com ; Aire-One@gitlab.com)
-----------------

-- require user rc.lua as a base config
-- user rc.lua file should be on a place loaded by awesomewm
require('rc')

local animated_wibox = require 'awesome-AnimationFramework.animated_wibox'

local wib = animated_wibox {
    ontop = true,
    visible = true,
    opacity = 1,
    x = 50,
    y = 50,
    width = 100,
    height = 100
}

-- wibox propterties are still there:
wib.width = 300
-- and new animation API is accessible:
print('There are currently ' .. #wib.animations .. ' animations registered.')

wib:connect_signal('mouse::enter', function ()
    -- clear all the current animations on wid
    wib:clear_animations()

    -- Register a new animation
    wib:register_animation {
        target = { width = 300 },
        easing = 'inOutCubic',
        duration = 0.325
    }

    wib:register_animation {
        target = { height = 300 },
        easing = 'inOutCubic',
        duration = 0.25,
        delay = 0.075
    }

    wib:start_animations()
end)

wib:connect_signal('mouse::leave', function ()
    wib:clear_animations()

    wib:register_animation {
        {
            target = { width = 100 },
            easing = 'inOutCubic',
            duration = 0.25,
            delay = 0.075
        },
        {
            target = { height = 100 },
            easing = 'inOutCubic',
            duration = 0.325
        }
    }

    wib:start_animations()
end)
