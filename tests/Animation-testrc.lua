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
--     -C /home/aireone/documents/prog/awesome-workspace/awesome-AnimationFramework/tests/Animation-testrc.lua \
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
require('rc')

-- load awesome wm libraries
local wibox = require('wibox')

-- Loading the library to test it
-- again, the file should be placed in a directory loaded by awesomewm
local Animation = require('awesome-AnimationFramework.Animation')

-- Material Design involve asymmetric transformations when
-- expending  and collapsing elements.
-- Here is an example of Material Design Animation :

-- The animation will be shown with an empty wibox
local animationWidget = wibox ({
    ontop = true,
    visible = true,
    opacity = 1,
    x = 50,
    y = 50,
    width = 100,
    height = 100
})

-- Expend transformation will occur when mouse::enter event is triggered
animationWidget:connect_signal('mouse::enter', function (c)
    -- An animation is an instance of Animation object.
    -- Material Design Animation for transformations uses a Bezier curve
    -- referred as "ease in out".
    -- (see https://material.io/guidelines/motion/duration-easing.html#duration-easing-natural-easing-curves)
    -- From the tween.lua documentation, "inOutCubic" is the more appropriated
    -- function type to use to copy this motion style.
    local animW = Animation(animationWidget,
        0.325, { width = 300 }, 'inOutCubic')
    local animH = Animation(animationWidget,
        0.325, { height = 300 }, 'inOutCubic')

    -- Once the Animations objects created,
    -- we can start them using :startAnimation method
    animW:startAnimation()

    -- Following Material Design guidelines, we need to add a small delay
    -- to recreate the asymmetric motion movement.
    -- (see https://material.io/guidelines/motion/transforming-material.html#transforming-material-rectangular-transformation)
    animH:startAnimation(0.075)

    -- Use signals to notify what happen with animW
    animW:connect_signal('anim::animation_started',
        function (s) print('anim stared', s) end)
    animW:connect_signal('anim::animation_updated',
        function (s, delta) print('anim updated', s, ' delta=' .. delta) end)
    animW:connect_signal('anim::animation_finished',
        function (s) print('anim finished', s) end)
    animW:connect_signal('anim::animation_stoped',
        function (s) print('I will never be called cauz the animation is never stopped', s) end)
end)

-- Same logic for collapse transformation on  mouse::leave event
animationWidget:connect_signal('mouse::leave', function (c)
    local animW = Animation(animationWidget, 0.325, { width = 100 }, 'inOutCubic')
    local animH = Animation(animationWidget, 0.325, { height = 100 }, 'inOutCubic')
    animH:startAnimation()
    animW:startAnimation(0.075)
end)
