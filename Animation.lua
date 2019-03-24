-----------------
-- Animation.lua
-- A simple OO overlay for tween.lua to perform Animations in Awesome WM.
--
-- Copyright (C) 2018-2019 Aire-One
--
-- Author : Aire-One (Aire-One@github.com ; Aire-One@gitlab.com)
-----------------

local gears = require('gears')
local glib = require('lgi').GLib
local GearsObject = gears.object
local GLibTimer = glib.Timer
local timer = gears.timer or require('timer')

local tween = require('awesome-AnimationFramework/tween-lua/tween')

-- Delay time for imitate a 60 FPS refresh rate
local ANIMATION_FRAME_DELAY = 0.0167


--- Start the animation.
-- @tparam Animation self The animation itself.
-- @tparam Number delay An additional delay before plaiing the animation
--   (in seconds).
local startAnimation = function (self, delay)
    if type(delay) == 'number' then
        self:setStartDelay(delay)
    end

    -- Temporary timer to create the start delay.
    -- Animation will be initialized and started after the delay.
    timer.start_new(self.delay, function ()
        self.tween = tween.new(self.duration, self.subject, self.target, self.easing)
        self.gTimer:start()
        self.timer = timer.start_new(ANIMATION_FRAME_DELAY, self.timer_function)
        self:emit_signal('anim::animation_started', self.delay)

        return false -- do not call again
    end)
end

--- Stop the animation ("force stop" it).
-- @tparam Animation self The animation itself.
local stopAnimation = function (self)
    self.tween = nil -- free the tween memory
    if self.timer and self.timer.started then
        self.timer:stop()
        self.timer = nil -- also free timer, it's a bit useless to keep it o/
        self:emit_signal('anim::animation_stoped')
    end
end

--- Change the delay before starting the animation in startAnimation method.
-- @tparam Animation self The animation itself.
-- @tparam Number delay An additional delay before plaiing the animation
--   (in seconds).
local setStartDelay = function (self, delay)
    self.delay = delay
end

local Animation = {}

--- Animation Constructor.
-- Creates a new Animation.
-- @tparam Table object The "object" to animate (should be a wibox).
-- @tparam Number duration The time the animation will last (in seconds).
-- @tparam Table end_step The finale state of the "object" attribus which change
--   while the animation is plaiing.
-- @tparam String function_type The name of the easing function to use.
-- @treturn Animation A new instance of Animation.
Animation.new = function (object, duration, end_step, function_type)
    local self = GearsObject()

    -- Object to animate (should be a widget)
    self.subject = object

    -- Duration of the animation in seconds
    self.duration = duration

    -- Finale state of of the animation : { prop = val [, ...] }
    self.target = end_step

    -- Animation Function type (string)
    self.easing = function_type

    -- Tween Object (manage the animation)
    self.tween = nil

    -- Timer to compute Animation Delta Time
    self.gTimer = GLibTimer()

    -- Last value of mGTimer:elapsed()
    self.last_elapsed = 0

    -- Timer of the animation
    self.timer = nil

    -- Delay before starting the animation when startAnimation is called
    self.delay = 0

    -- Timer callcabk
    self.timer_function = function ()
        -- compute delta time
        local time = self.gTimer:elapsed()
        local delta = time - self.last_elapsed
        self.last_elapsed = time

        local completed = self.tween:update(delta)
        self:emit_signal('anim::animation_updated', delta, time)

        -- notify awesome the object need to be redrawn
        --mObject:emit_signal('widget::redraw_needed')

        if completed then
            self:emit_signal('anim::animation_finished')
            return false -- stop calling the function
        end

        -- call again the function after cooldown
        return true
    end

    -- We implement methods like this for backward compatibility.
    self.startAnimation = startAnimation
    self.stopAnimation = stopAnimation
    self.setStartDelay = setStartDelay

    return self
end


-- Return Animation.new to ensure backward compatibility.
-- When this refactoring will be completed, we will use metatable.
return Animation.new
