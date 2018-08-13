-----------------
-- Animation.lua
-- A simple OO overlay for tween.lua to perform Animations in Awesome WM.
--
-- Copyright (C) 2018 Aire-One
--
-- Author : Aire-One (Aire-One@github.com ; Aire-One@gitlab.com)
-----------------

local gears = require('gears')
local GearsObject = gears.object
local GLibTimer = require('lgi').GLib.Timer
local timer = gears.timer or require('timer')

local tween = require('awesome-AnimationFramework/tween-lua/tween')

-- Delay time for imitate a 60 FPS refresh rate
local ANIMATION_FRAME_DELAY = 0.0167

--- Animation
-- Contructor args :
-- object : Object to animate
-- duration : Animation duration
-- end_step : finale state of the object
-- function_type : function name to use for the animation
local Animation = function (object, duration, end_step, function_type)
    local self = GearsObject()

    -- Object to animate (should be a widget)
    local mObject = object

    -- Duration of the animation in seconds
    local mDuration = duration

    -- Finale state of of the animation : { prop = val [, ...] }
    local mEndStep = end_step

    -- Animation Function type (string)
    local mFuncType = function_type

    -- Tween Object (manage the animation)
    local mTween = nil

    -- Timer to compute Animation Delta Time
    local mGTimer = GLibTimer()

    -- Last value of mGTimer:elapsed()
    local GTimerLast = 0

    -- Timer of the animation
    local mTimer = nil

    -- Delay before starting the animation when startAnimation is called
    local mDelay = 0

    -- Timer callcabk
    local mTimerFunction = function ()
        -- compute delta time
        local time = mGTimer:elapsed()
        delta = time - GTimerLast
        GTimerLast = time

        local completed = mTween:update(delta)
        self:emit_signal('anim::animation_updated', delta, time)

        -- notify awesome the object need to be redrawn
        mObject:emit_signal('widget::redraw_needed')

        if completed then
            self:emit_signal('anim::animation_finished')
            return false -- stop calling the function
        end

        -- call again the function after cooldown
        return true
    end

    --- Start the animation
    self.startAnimation = function (self, delay)
        if type(delay) == 'number' then
            self:setStartDelay(delay)
        end

        -- Temp timer to create the start delay.
        -- Animation will be init and started after mDelay seconds.
        timer.start_new(mDelay, function ()
            mTween = tween.new(mDuration, mObject, mEndStep, mFuncType)
            mGTimer:start()
            mTimer = timer.start_new(ANIMATION_FRAME_DELAY, mTimerFunction)
            self:emit_signal('anim::animation_started', mDelay)

            return false -- do not call again
        end)
    end

    --- Stop the animation ("force stop" it)
    self.stopAnimation = function (self)
        mTween = nil -- free the tween memory
        if mTimer and mTimer.started then
            mTimer:stop()
            mTimer = nil -- also free timer, it's a bit useless to keep it o/
            self:emit_signal('anim::animation_stoped')
        end
    end

    --- Change the delay before starting the animation in startAnimation method
    self.setStartDelay = function (self, delay)
        mDelay = delay
    end

    return self
end

return Animation
