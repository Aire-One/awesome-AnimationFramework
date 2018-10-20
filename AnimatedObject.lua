-----------------
-- Animation.lua
-- A wrapper to easily manage objects and their animations.
--
-- Copyright (C) 2018 Aire-One
--
-- Author : Aire-One (Aire-One@github.com ; Aire-One@gitlab.com)
-----------------

local GearsObject = require('gears.object')

local Animation = require('awesome-AnimationFramework/Animation')

local array = {
    foreach = function (array, callback)
        for i=1, #array do
            (function (i, element)
                callback(i, element)
            end)(i, array[i])
        end
    end,
    insert = function (array, element)
        array[#array + 1] = element
        return array
    end,
    find = function (array, element)
        for i=1, #array do
            if array[i] == element then
                return i
            end
        end
        return -1
    end,
    isEmpty = function (array)
        return #array == 0 or array == {}
    end
}

--- Wrapper for Animated objects.
-- This container associates an Object with its Animations, giving a better
-- interface to manage them. It also provide some signals for events handling.
-- @arg object The Object to Wrap.
-- @ret A Wrapper instance.
local AnimatedObject = function (object)
    local self = GearsObject()

    local mObject = object
    local mAnimations = {}

    local animFinishedSignal = function (s)
        local anim_index = array.find(mAnimations, s)
        if anim_index ~= -1 then
            table.remove(mAnimations, anim_index)
        end

        if array.isEmpty(mAnimations) then
            self:emit_signal('anim::animation_finished')
        end
    end

    --- Add an animation to the list.
    local addAnimation = function (animation)
        array.insert(mAnimations, animation)
    end

    --- Accessor to Object.
    self.object = function (self)
        return mObject
    end

    --- Accessor to Animations.
    self.animations = function (self)
        return {
            list = mAnimations,
            length = #mAnimations,
            start = function () self:startAnimations() end,
            stop = function () self:stopAnimations() end,
            clear = function() self:clearAnimations() end
        }
    end

    --- Create a new Animation.
    -- @arg end_step Object representing the final state of the animation.
    -- @arg function_type Function name to use for the animation.
    -- @arg duration Animation duration.
    self.createAnimation = function (self, end_step, function_type, duration)
            local anim = Animation(mObject, duration, end_step, function_type)
            anim:connect_signal('anim::animation_finished', animFinishedSignal)
            addAnimation(anim)
            return anim
    end

    --- Start all animations.
    self.startAnimations = function (self)
        array.foreach(mAnimations, function(i, e)
            e:startAnimation()
        end)
    end

    --- Stop all animations.
    self.stopAnimations = function (self)
        array.foreach(mAnimations, function(i, e)
            e:stopAnimation()
        end)
    end

    --- Clear the animations list.
    self.clearAnimations = function (self)
        self:stopAnimations()
        mAnimations = {}
    end

    return self
end

return AnimatedObject
