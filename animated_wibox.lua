-----------------
-- animated_wibox.lua
-- An implementation of Awesome WM wibox to perform animations with tween.lua
-- as a back-end in Awesome WM.
--
-- @usage
-- local my_wibox = animated_wibox {
--
-- }
--
-- @author Aire-One (Aire-One@github.com ; Aire-One@gitlab.com)
-- @copyright 2019 Aire-One
-----------------

local gears = require('gears')
local gtable = gears.table
local wibox = require('wibox')

local Animation = require('awesome-AnimationFramework/Animation')

local animated_wibox = {}
local mt = {}

animated_wibox.register_animation = function (self, args)
    -- If caller wants to creating a new single animation.
    if args.target ~= nil and args.easing ~= nil and args.duration ~= nil  then
        self:register_animation { Animation(args) }
        return
    end

    for id,animation in pairs(args) do
        -- We use the startAnimation method to identify Animation objects
        if type(animation.startAnimation) == 'function' then
            -- raise an error if a subject is already specified and it's not
            -- the current wibox
            if animation.subject == nil then
                animation.subject = self
            end
            assert(animation.subject == self)

            if not self.animations[id] then self.animations[id] = {} end
            table.insert(self.animations[id], animation)
        else
            if type(animation.target) == 'table' then
                self:register_animation { [id] = Animation(animation) }
            else
                -- We can have an array of animations relative to the same id
                for _,anim in pairs(animation) do
                    self:register_animation { [id] = anim }
                end
            end
        end
    end
end

animated_wibox.start_animations = function (self, id)
    -- Helper function to iterate through a group of animation and start them.
    local start_group_anim = function (group)
        for _,anim in pairs(group) do
            anim:startAnimation()
        end
    end

    if id then
        start_group_anim(self.animations[id])
    else
        for _,grp_anim in pairs(self.animations) do
            start_group_anim(grp_anim)
        end
    end
end

animated_wibox.stop_animations = function (self, id)
    -- Helper function to iterate through a group of animation and stop them.
    local stop_group_anim = function (group)
        for _,anim in pairs(group) do
            anim:stopAnimation()
        end
    end

    if id then
        stop_group_anim(self.animations[id])
    else
        for _,grp_anim in pairs(self.animations) do
            stop_group_anim(grp_anim)
        end
    end
end

animated_wibox.clear_animations = function (self, id)
    self:stop_animations(id)

    if id then
        self.animations[id] = nil
    else
        self.animations = {}
    end
end

animated_wibox.play_animation = function (self, animations)
    self:clear_animations()
    self:register_animation(animations)
    self:start_animations()
end

animated_wibox.animate = function (self, animations)
    for id,anim in pairs(animations) do
        self:clear_animations(id)
        self:register_animation { [id] = anim }
        self:start_animations(id)
    end
end

animated_wibox.new = function (args)
    local self = wibox(args)
    gtable.crush(self, animated_wibox, true)

    self.animations = {}

    if args.animations ~= nil then
        for i,anim in ipairs(args.animations) do -- luacheck: ignore i
            self.register_animation(anim)
        end
    end

    return self
end


mt.__call = function (self, ...)
    return animated_wibox.new(...)
end

return setmetatable(animated_wibox, mt)
