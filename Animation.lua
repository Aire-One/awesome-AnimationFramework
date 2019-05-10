-----------------
-- Animation.lua
-- A simple object-oriented overlay for tween.lua to perform Animations in
-- Awesome WM.
--
-- The Animation module should be use to animate your wiboxes and widgets.
-- It is an abstraction layer over the `tween.lua` library written with Awesome
-- WM in mind. Please note this is hightly experimental and you shouldn't
-- perform animations from Awesome WM itself.
--
-- To use this OO abstraction you should first define your subject.
-- A subject can be either, a wiboxes or a widget.
-- It is not recommanded to use a client. A client is managed by the layout API
-- and modifiing its geometries will not work at all.
-- It is however possible to make it work with floating clients (but still not
-- recommanded).
--
-- @usage
-- local my_animation = AnimationFramework.Animation(my_wibox, 0.42,  { ... }, 'linear')
--
-- @author Aire-One (Aire-One@github.com ; Aire-One@gitlab.com)
-- @copyright 2018 - 2019 Aire-One
-----------------

local glib = require('lgi').GLib
local gears = require('gears')
local gobject = gears.object
local gtable = gears.table

local deprecate = gears.debug.deprecate


local tween = require('awesome-AnimationFramework/tween-lua/tween')

local time_conversion = {
    micro_to_milli = function (micro) return micro / 1000 end,
    second_to_micro = function (sec) return  sec * 1000000 end,
    second_to_milli = function (sec) return sec * 1000 end
}


local Animation = {
    --- Time between two frames in milliseconds (default emulate 60 FPS).
    -- Default value is set to `16.7` to emulate a 60 FPS animation.
    ANIMATION_FRAME_DELAY = 16.7
}
local mt = {}

--- Start the animation.
-- @tparam Animation self The animation itself.
-- @tparam[opt] Number delay An additional delay before plaiing the animation
--   (in seconds).
-- @method Animation.startAnimation
Animation.startAnimation = function (self, delay)
    if type(delay) == 'number' then
        self.delay = time_conversion.second_to_milli(delay)
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
-- @method Animation.stopAnimation
Animation.stopAnimation = function (self)
    self.tween = nil -- free the tween memory
    if type(self.timer) == "table" and self.timer.stared then
        glib.source_remove(self.timer)
        self.timer = nil  -- this reference no longer exists in glib's memory

        self:emit_signal('anim::animation_stoped')
    end
end

--- Change the delay before starting the animation in startAnimation method.
-- This method is deprecated, please use the `delay` property instead.
-- @tparam Animation self The animation itself.
-- @tparam Number delay An additional delay before plaiing the animation
--   (in seconds).
-- @deprecated Animation.setStartDelay
Animation.setStartDelay = function (self, delay)
    deprecate("Please use `Animation.delay` property instead.")

    self.delay = time_conversion.second_to_micro(delay)
end

--- Animation Constructor.
-- Creates a new Animation.
-- @tparam Table subject The subject to animate (should be a wibox).
-- @tparam Number duration The time the animation will last (in seconds).
-- @tparam Table target Representes the final state of the subject at the
--   animation end. This table must be a table with at least the same keys as
--   the _subject_. Other keys will be ignored.
-- @tparam callback easing Function name or function declaration.
-- @treturn Animation A new instance of Animation.
-- @deprecated Animation.deprecated_new
Animation.deprecated_new = function (subject, duration, target, easing)
    return Animation {
        subject = subject,
        duration = duration,
        target = target,
        easing = easing
    }
end

--- Animation Constructor.
-- Creates a new Animation.
-- @tparam table args
-- @tparam table args.subject The subject to animate (should be a wibox).
-- @tparam number args.duration The time the animation will last (in seconds).
-- @tparam table args.target Representes the final state of the subject at the
--   animation end. This table must be a table with at least the same keys as
--   the _subject_. Other keys will be ignored.
-- @tparam string|function args.easing Function name or function declaration.
--   (See Tween.lua documentation)
-- @tparam number args.delay Delay before starting the animation when
--   startAnimation is called (second).
-- @treturn Animation A new instance of Animation.
-- @function Animation.new
-- @usage local my_animation = Animation {
--    subject = my_wibox,
--    duration = 0.3,
--    target = { x = 100 },
--    easing = 'linear'
-- }
Animation.new = function (args)
    local self = gobject()
    gtable.crush(self, Animation, true)

    local args = args or {} -- luacheck: ignore args

    --- Subject of the animation (should be a wibox).
    -- @property subject
    -- @tparam table subject
    self.subject = args.subject

    --- Duration of the animation in seconds.
    -- @property duration
    -- @tparam number duration
    self.duration = time_conversion.second_to_micro(args.duration)

    --- Finale state of of the animation.
    -- This table must be a table with at least the same keys as
    --   the _subject_. Other keys will be ignored. : { prop = val [, ...] }
    -- @property target
    -- @tparam table target
    self.target = args.target

    --- Motion function for the easing.
    -- @property easing
    -- @tparam string|function easing
    self.easing = args.easing

    -- Delay before starting the animation when startAnimation is called (microsecond).
    -- @property delay
    -- @tparam number delay
    self.delay = time_conversion.second_to_milli(args.delay or 0)

    -- Tween Object (manage the animation)
    self.tween = nil

    -- Last value of mGTimer:elapsed()
    self.last_elapsed = 0

    -- Timer of the animation
    -- Glib.Timer's reference
    self.timer = nil

    -- Timer callcabk
    self.timer_function = function ()
        -- check if the animation was stoped while we were sleeping
        if self.tween == nil then return false end

        -- compute delta time
        local time = glib.get_monotonic_time()
        local delta = time - self.last_elapsed
        self.last_elapsed = time

        local completed = self.tween:update(delta)

        self:emit_signal('anim::animation_updated',
            time_conversion.micro_to_milli(delta),
            time_conversion.micro_to_milli(time))

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

--- The animation is started.
--
-- This signal is emited when the animation starts.
-- @signal anim::animation_started
-- @tparam number delay The additional delay before the animation really starts.

--- The animation is stoped.
--
-- This signal is emited when the animation stops.
-- An animation stop is manually called by the `Animation.stopAnimation` method.
-- @signal anim::animation_stoped

--- The animation is finished.
--
-- This signal is emited when the animation is finished.
-- @signal anim::animation_finished

--- The animation is updated.
--
-- This signal is emited at each animation updates.
-- @signal anim::animation_updated
-- @tparam number delta The delta time since last animation update.
-- @tparam number time The total time the animation is running.


mt.__call = function (self, ...)
    --
    -- This section will be deleted at release 1.0 with all deprecated stuff
    if #{...} > 1 then
        deprecate("Please use the new constructor arguments style.")
        return Animation.deprecated_new(...)
    end
    --

    return Animation.new(...)
end


return setmetatable(Animation, mt)
