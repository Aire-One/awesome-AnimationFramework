-----------------
-- Animation.lua
-- A wrapper to easily manage objects and their animations.
--
-- Copyright (C) 2018 - 2019 Aire-One
--
-- Author : Aire-One (Aire-One@github.com ; Aire-One@gitlab.com)
-----------------

local gears = require('gears')
local GearsObject = gears.object

local Animation = require('awesome-AnimationFramework/Animation')

local array = {
    foreach = function (array, callback)
        for i=1, #array do
            (function (i, element) -- luacheck: ignore shadowing i
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

--- Add an animation to the list of animations to play on the subject.
-- @tparam AnimatedObject self The AnimatedObject itself.
-- @tparam Animation The animation to add to the pliing list.
local addAnimation = function (self, animation)
    array.insert(self.anims, animation)
end

--- Create a new Animation.
-- @tparam AnimatedObject self The AnimatedObject itself.
-- @tparam end_step Object representing the final state of the animation.
-- @tparam function_type Function name to use for the animation.
-- @tparam duration Animation duration.
local createAnimation = function (self, end_step, function_type, duration)
        local anim = Animation(self.subject, duration, end_step, function_type)
        anim:connect_signal('anim::animation_finished', self.anim_finiched_signal)
        self:addAnimation(anim)
        return anim
end

--- Start all animations registered in the animation list.
-- @tparam AnimatedObject self The AnimatedObject itself.
-- @tparam function final_callback An optionable final callback to call at the
--   very end of the plaiing process.
local startAnimations = function (self, final_callback)
    if type(final_callback) == 'function' then
        self.final_callback = final_callback
    end

    array.foreach(self.anims, function(i, e) -- luacheck: ignore i
        e:startAnimation()
    end)
end

--- Stop all animations.
-- @tparam AnimatedObject self The AnimatedObject itself.
local stopAnimations = function (self)
    array.foreach(self.anims, function(i, e) -- luacheck: ignore i
        e:stopAnimation()
    end)
end

--- Clear the animations list.
-- @tparam AnimatedObject self The AnimatedObject itself.
local clearAnimations = function (self)
    self:stopAnimations()
    self.anims = {}
    self.final_callback = nil
end


local AnimatedObject =  {}

--- Wrapper for Animated objects.
-- This container associates an Object with its Animations, giving a better
-- interface to manage them. It also provide some signals for events handling.
-- @tparam Table object The "object" to animate (should be a wibox).
-- @treturn AnimatedObject An AnimatedObject instance.
AnimatedObject.new = function (object)
    local self = GearsObject()

    self.subject = object
    self.anims = {}
    self.final_callcack = nil

    self.anim_finiched_signal = function (s)
        local anim_index = array.find(self.anims, s)
        if anim_index ~= -1 then
            table.remove(self.anims, anim_index)
        end

        if array.isEmpty(self.anims) then
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

    -- We implement methods like this for backward compatibility.
    self.addAnimation = addAnimation
    self.createAnimation = createAnimation
    self.startAnimations = startAnimations
    self.stopAnimations = stopAnimations
    self.clearAnimations = clearAnimations

    return self
end


-- Return AnimatedObject.new to ensure backward compatibility.
-- When this refactoring will be completed, we will use metatable.
return AnimatedObject.new
