-----------------
-- Animation.lua
-- A wrapper to easily manage objects and their animations.
--
-- Copyright (C) 2018 - 2019 Aire-One
--
-- Author : Aire-One (Aire-One@github.com ; Aire-One@gitlab.com)
-----------------

local gears = require('gears')
local gobject = gears.object
local gtable = gears.table

local Animation = require('awesome-AnimationFramework/Animation')


local AnimatedObject =  {}
local mt = {}

--- Add an animation to the list of animations to play on the subject.
-- @tparam AnimatedObject self The AnimatedObject itself.
-- @tparam Animation animation The animation to add to the pliing list.
AnimatedObject.addAnimation = function (self, animation)
    self.anims[#self.anims + 1] = animation
end

--- Create a new Animation.
-- @tparam AnimatedObject self The AnimatedObject itself.
-- @tparam table end_step representing the final state of the animation.
-- @tparam callback function_type Function name to use for the animation.
-- @tparam number duration Animation duration.
AnimatedObject.createAnimation = function (self, end_step, function_type, duration)
        local anim = Animation(self.subject, duration, end_step, function_type)
        anim:connect_signal('anim::animation_finished', self.anim_finiched_signal)
        self:addAnimation(anim)
        return anim
end

--- Start all animations registered in the animation list.
-- @tparam AnimatedObject self The AnimatedObject itself.
-- @tparam callback final_callback An optionable final callback to call at the
--   very end of the plaiing process.
AnimatedObject.startAnimations = function (self, final_callback)
    if type(final_callback) == 'function' then
        self.final_callback = final_callback
    end

    for i,anim in ipairs(self.anims) do -- luacheck: ignore i
        anim:startAnimation()
    end
end

--- Stop all animations.
-- @tparam AnimatedObject self The AnimatedObject itself.
AnimatedObject.stopAnimations = function (self)
    for i,anim in ipairs(self.anims) do -- luacheck: ignore i
        anim:stopAnimation()
    end
end

--- Clear the animations list.
-- @tparam AnimatedObject self The AnimatedObject itself.
AnimatedObject.clearAnimations = function (self)
    self:stopAnimations()
    self.anims = {}
    self.final_callback = nil
end

--- Wrapper for Animated objects.
-- This container associates an Object with its Animations, giving a better
-- interface to manage them. It also provide some signals for events handling.
-- @tparam table object The "object" to animate (should be a wibox).
-- @treturn AnimatedObject An AnimatedObject instance.
AnimatedObject.new = function (object)
    local self = gobject()
    gtable.crush(self, AnimatedObject, true)

    self.subject = object
    self.anims = {}
    self.final_callcack = nil

    self.anim_finiched_signal = function (s)
        local anim_index = gtable.hasitem(self.anims, s)
        if anim_index ~= -1 then
            table.remove(self.anims, anim_index)
        end

        -- if array.isEmpty(self.anims) then
        if #self.anims == 0 then
            self:emit_signal('anim::animation_finished')

            if type(self.final_callback) == 'function' then
                self.final_callback(self)
                self.final_callback = nil
            end
        end
    end

    --- Accessor to Object.
    -- It's keept here for backward conmpatibility but will be deleted at merge.
    self.object = function (self)
        return self.subject
    end

    --- Accessor to Animations.
    self.animations = function (self)
        return {
            list = self.anims,
            length = #self.anims,
            start = function () self:startAnimations() end,
            stop = function () self:stopAnimations() end,
            clear = function() self:clearAnimations() end
        }
    end

    return self
end

mt.__call = function (self, ...)
    return AnimatedObject.new(...)
end

return setmetatable(AnimatedObject, mt)
