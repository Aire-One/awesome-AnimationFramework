-----------------
-- test/rc.lua
-- A Simple wrapper around the user rc.lua with some tests for the framework.
-- This test file will show how to use the awesome-AnimationFramework.Animation
-- component. Please read the comments to understand what happen.
--
-- NOTE :
-- I run this file using my patched version of the awmtt tool available at :
-- https://github.com/Aire-One/awmtt
-- here is the command I run :
-- ```
--     awmtt start -B ~/documents/prog/awesome/build/awesome \
--     -C /home/aireone/documents/prog/awesome-workspace/awesome-AnimationFramework/tests/AnimatedObject-testrc.lua \
--     -a '--search /home/aireone/documents/prog/awesome/build/lib' \
--     -a '--search /home/aireone/documents/prog/awesome-workspace'
-- ```
-- -B : use the awesome binary I build from my awesome wm git repo clone
-- -C : use this file as the main rc.lua entry for awesome
-- -a : add customs directories as libraries for awesome
--     (- awesome generated libraries from my clone
--     - my development directory containing awesome-AnimationFramework)
--
-- Copyright (C) 2018 Aire-One
--
-- Author : Aire-One (Aire-One@github.com ; Aire-One@gitlab.com)
-----------------

-- require user rc.lua as a base config
-- user rc.lua file should be on a place loaded by awesomewm
require 'rc'

-- load awesome wm libraries
local wibox = require 'wibox'

-- Loading the library to test it
-- again, the file should be placed in a directory loaded by awesomewm
local AnimatedObject = require 'awesome-AnimationFramework.AnimatedObject'

local wib = wibox {
    ontop = true,
    visible = true,
    x = 50,
    y = 50,
    width = 100,
    height = 100
}

-- animatedWibox is the object we will use now
local animatedWibox = AnimatedObject(wib)

-- animatedWibox contains your wibox and you still can access it:
animatedWibox.subject.width = 300
-- you also can access to all the animations registered for you widget:
print('There are currently ' .. #animatedWibox.anims
    .. ' animations registered.')

animatedWibox:connect_signal('anim::animation_finished', function (s)
    print(s, 'anim finished')
end)

wib:connect_signal('mouse::enter', function ()
    -- clear all the current animations on wid
    animatedWibox:clearAnimations()

    -- Register a new animation
    animatedWibox:register_animation {
        target = { width = 300 },
        easing = 'inOutCubic',
        duration = 0.325
    }

    -- you can also get back the Animation object...
    local animH = animatedWibox:register_animation {
        target = { height = 300 },
        easing = 'inOutCubic',
        duration = 0.25
    }

    -- ... and use it just like in the previous example:
    -- you can add the delay (0.075 seconds * 1000 to convert to milliseconds)
    animH.delay = 75
    -- or connect its own signals
    animH:connect_signal('anim::animation_started',
        function (s) print('anim stared', s) end)

    -- start all registered animations:
    animatedWibox:startAnimations()
end)

wib:connect_signal('mouse::leave', function ()
    animatedWibox:clearAnimations()

    animatedWibox:register_animation {
        target = { width = 100 },
        easing = 'inOutCubic',
        duration = 0.25,
        delay = 0.075
    }
    animatedWibox:register_animation {
        target = { height = 100 },
        easing = 'inOutCubic',
        duration = 0.325
    }

    animatedWibox:startAnimations()
end)
