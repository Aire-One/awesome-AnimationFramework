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
    for i,animation in ipairs(args) do -- luacheck: ignore i
        -- We use the startAnimation method to identify Animation objects
        if type(animation.startAnimation) == 'function' then
            -- raise an error if a subject is already specified and it's not
            -- the current wibox
            if animation.subject == nil then
                animation.subject = self
            end
            assert(animation.subject == self)

            self.animations[#self.animations + 1] = animation
        else
            self:register_animation { Animation(animation) }
        end
    end

    -- creating a single animation
    if args.target ~= nil and args.easing ~= nil and args.duration ~= nil  then
        self:register_animation { Animation(args) }
    end
end

animated_wibox.start_animations = function (self)
    for i,anim in ipairs(self.animations) do -- luacheck: ignore i
        anim:startAnimation()
    end
end

animated_wibox.stop_animations = function (self)
    for i,anim in ipairs(self.animations) do -- luacheck: ignore i
        anim:stopAnimation()
    end
end

animated_wibox.clear_animations = function (self)
    self:stop_animations()
    self.animations = {}
end

animated_wibox.play_animation = function (self, animations)
    self:clear_animations()
    self:register_animation(animations)
    self:start_animations()
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
