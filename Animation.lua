-----------------
-- Animation.lua
-- A simple OO overlay for tween.lua to perform Animations in Awesome WM.
--
-- Copyright (C) 2018-2019 Aire-One
--
-- Author : Aire-One (Aire-One@github.com ; Aire-One@gitlab.com)
-----------------

local glib = require('lgi').GLib
local gears = require('gears')
local gobject = gears.object
local gtable = gears.table

local tween = require('awesome-AnimationFramework/tween-lua/tween')


local Animation = {
    --- Time between two frames in milliseconds (default emulate 60 FPS).
    -- Default value is set to `16.7` to emulate a 60 FPS animation.
    ANIMATION_FRAME_DELAY = 16.7
}
local mt = {}

--- Start the animation.
-- @tparam Animation self The animation itself.
-- @tparam Number delay An additional delay before plaiing the animation
--   (in seconds).
Animation.startAnimation = function (self, delay)
    if type(delay) == 'number' then
        self:setStartDelay(delay)
    end

    -- Temporary timer to create the start delay.
    -- Animation will be initialized and started after the delay.
    glib.timeout_add(glib.PRIORITY_DEFAULT, self.delay, function ()
        self.last_elapsed = glib.get_monotonic_time()

        self.tween = tween.new(
            self.duration,
            self.subject,
            self.target, self.easing)

        self.timer = glib.timeout_add(
            glib.PRIORITY_DEFAULT,
            self.ANIMATION_FRAME_DELAY,
            self.timer_function)

        self:emit_signal('anim::animation_started', self.delay)

        return false -- do not call again
    end)
end

--- Stop the animation ("force stop" it).
-- @tparam Animation self The animation itself.
Animation.stopAnimation = function (self)
    self.tween = nil -- free the tween memory
    if self.timer and self.timer.started then
        glib.source_remove(self.timer)
        self.timer = nil  -- this reference no longer exists in glib's memory

        self:emit_signal('anim::animation_stoped')
    end
end

--- Change the delay before starting the animation in startAnimation method.
-- @tparam Animation self The animation itself.
-- @tparam Number delay An additional delay before plaiing the animation
--   (in seconds).
Animation.setStartDelay = function (self, delay)
    self.delay = delay
end

--- Animation Constructor.
-- Creates a new Animation.
-- @tparam Table object The "object" to animate (should be a wibox).
-- @tparam Number duration The time the animation will last (in seconds).
-- @tparam Table end_step The finale state of the "object" attribus which change
--   while the animation is plaiing.
-- @tparam String function_type The name of the easing function to use.
-- @treturn Animation A new instance of Animation.
Animation.new = function (object, duration, end_step, function_type)
    local self = gobject()
    gtable.crush(self, Animation, true)

    -- Object to animate (should be a widget)
    self.subject = object

    -- Duration of the animation in seconds
    -- We currently work with micoseconds. 1 microsecond = 1e-6 second
    self.duration = duration * 1000000

    -- Finale state of of the animation : { prop = val [, ...] }
    self.target = end_step

    -- Animation Function type (string)
    self.easing = function_type

    -- Tween Object (manage the animation)
    self.tween = nil

    -- Last value of mGTimer:elapsed()
    self.last_elapsed = 0

    -- Timer of the animation
    -- Glib.Timer's reference
    self.timer = nil

    -- Delay before starting the animation when startAnimation is called
    self.delay = 0

    -- Timer callcabk
    self.timer_function = function ()
        -- compute delta time
        local time = glib.get_monotonic_time()
        local delta = time - self.last_elapsed
        self.last_elapsed = time

        local completed = self.tween:update(delta)

        -- TODO : specify where to use seconds/milli/micro
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

    return self
end


mt.__call = function (self, ...)
    return Animation.new(...)
end


return setmetatable(Animation, mt)
