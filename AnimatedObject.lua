-----------------
-- AnimatedObject.lua
-- A wrapper to easily manage objects and their animations.
--
-- The AnimatiedObject module should be use to animate your wiboxes and widgets.
-- It is an abstraction layer over the Animation module. You can use the
-- AnimatedObject module to wrap up your UI components created with the standard
-- library of Awesome WM and animations.
--
-- To use this wrapper you should first define your subject.
-- To use this OO abstraction you should first define your subject.
-- A subject can be either, a wiboxes or a widget.
-- It is not recommanded to use a client. A client is managed by the layout API
-- and modifiing its geometries will not work at all.
-- It is however possible to make it work with floating clients (but still not
-- recommanded).
--
-- Create your AnimatedObject instance with your wibox:
--     local my_wibox = wibox { ... }
--     local my_animated_object(my_wibox)
--
-- @usage
-- local my_animated_object = AnimationFramework.AnimatedObject(my_wibox)
--
-- @author Aire-One (Aire-One@github.com ; Aire-One@gitlab.com)
-- @copyright 2018 - 2019 Aire-One
-----------------

local gears = require('gears')
local gobject = gears.object
local gtable = gears.table

local deprecate = gears.debug.deprecate

local Animation = require('awesome-AnimationFramework/Animation')


local AnimatedObject =  {}
local mt = {}


--- Add an animation to the list of animations to play on the subject.
-- @tparam AnimatedObject self The AnimatedObject itself.
-- @tparam Animation animation The animation to add to the pliing list.
-- @deprecated AnimatedObject.addAnimation
AnimatedObject.addAnimation = function (self, animation)
    deprecate("AnimatedObject.register_animation")

    self.anims[#self.anims + 1] = animation
end

--- Create a new Animation.
-- @tparam AnimatedObject self The AnimatedObject itself.
-- @tparam table target Representes the final state of the subject at the
--   animation end. This table must be a table with at least the same keys as
--   the _subject_. Other keys will be ignored.
-- @tparam callback easing Function name or function declaration.
-- @tparam number duration Animation duration.
-- @deprecated AnimatedObject.createAnimation
AnimatedObject.createAnimation = function (self, target, easing, duration)
    deprecate("AnimatedObject.register_animation")

    local anim = Animation(self.subject, duration, target, easing)
    anim:connect_signal('anim::animation_finished', self.anim_finiched_signal)
    self:addAnimation(anim)
    return anim
end

--- Register an animation to be played.
-- @tparam AnimatedObject self The AnimatedObject itself.
-- @tparam table args table with options for the animation to register (other
--   fields will be ignored if `args.animation` is specified).
-- @tparam Animation args.animation The animation to register.
-- @tparam table args.target Representes the final state of the subject at the
--   animation end. This table must be a table with at least the same keys as
--   the _subject_. Other keys will be ignored.
-- @tparam callback args.easing Function name or function declaration.
-- @tparam number args.duration Animation duration.
-- @tparam[opt] number args.delay An additional delay to wait before plaiing the
--   animation when _start_ is triggered.
-- @method AnimatedObject.register_animation
-- @usage my_animated_object:register_animation { animation = my_animation, delay = 0.5 }
-- @usage my_animated_object:register_animation {
--     target = { ... },
--     easing = 'linear',
--     duration = 0.34
-- }
-- @usage my_animated_object:register_animation {
--     target = { ... },
--     duration = 0.34,
--     delay = 0.5
-- }
AnimatedObject.register_animation = function (self, args)
    if not args.animation then
        args.animation = self:register_animation {
            animation = Animation {
                subject = self.subject,
                duration = args.duration or 0,
                target = args.target or {},
                easing = args.easing or nil
            }
        }
    end

    self.anims[#self.anims + 1] = args.animation
    self.anims[#self.anims]:connect_signal('anim::animation_finished',
        self.anim_finiched_signal)

    if args.delay then
        args.delay = args.delay * 1000
        self.anims[#self.anims].delay = args.delay
    end

    return args.animation
end

--- Start all animations registered in the animation list.
-- @tparam AnimatedObject self The AnimatedObject itself.
-- @tparam callback final_callback An optionable final callback to call at the
--   very end of the plaiing process.
-- @method AnimatedObject.startAnimations
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
-- @method AnimatedObject.stopAnimations
AnimatedObject.stopAnimations = function (self)
    for i,anim in ipairs(self.anims) do -- luacheck: ignore i
        anim:stopAnimation()
    end
end

--- Clear the animations list.
-- @tparam AnimatedObject self The AnimatedObject itself.
-- @method AnimatedObject.clearAnimations
AnimatedObject.clearAnimations = function (self)
    self:stopAnimations()
    self.anims = {}
    self.final_callback = nil
end


--- Accessor to Animations.
-- This method gives a table with quick access and control over registered
-- animations.
-- @tparam AnimatedObject self The AnimatedObject itself.
-- @treturn[1] table A table with quick access to registered animations.
-- @treturn[1] table list The List of animation currently registered.
-- @treturn[1] number length The length of the list (number of registered animations).
-- @treturn[1] function start Start all the registered animations.
-- @treturn[1] function stop Stop all the registered animations.
-- @treturn[1] function clear Stop and clear the list of registered animations.
-- @deprecated AnimatedObject.animations
AnimatedObject.animations = function (self)
    deprecate()

    return {
        list = self.anims,
        length = #self.anims,
        start = function () self:startAnimations() end,
        stop = function () self:stopAnimations() end,
        clear = function() self:clearAnimations() end
    }
end

--- Wrapper for Animated objects.
-- This container associates an Object with its Animations, giving a better
-- interface to manage them. It also provide some signals for events handling.
-- @tparam table object The "object" to animate (should be a wibox).
-- @treturn AnimatedObject An AnimatedObject instance.
-- @function AnimatedObject.new
AnimatedObject.new = function (object)
    local self = gobject()
    gtable.crush(self, AnimatedObject, true)

    --- Subject of the animation (should be a wibox).
    -- @property subject
    -- @tparam table subject
    self.subject = object

    --- List of registered animations.
    --
    -- This table is a list with all the registered animations for the given
    -- subject. Each animation registered is an instance of Animation.
    -- @property anims
    -- @tparam table anims
    -- @see Animation
    self.anims = {}

    --- Callback called at the very end of all registered animations.
    --
    -- This callback is called when all registered animations are finished.
    -- This callback is now deprecated and you should use signals instead.
    -- @deprecatedproperty final_callback
    -- @tparam function final_callback
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
                deprecate('final_callback will be deprecated, please use signals instead.')

                self.final_callback(self)
                self.final_callback = nil
            end
        end
    end

    --- Accessor to Object.
    -- It's keept here for backward conmpatibility but will be deleted at merge.
    -- @deprecated object
    self.object = function (self)
        deprecate()

        return self.subject
    end

    return self
end

--- All the registered animations are finished.
--
-- This signal is emited at the very end of all the registered animations, when
-- they are all finished.
-- @signal anim::animation_finished


mt.__call = function (self, ...)
    return AnimatedObject.new(...)
end

return setmetatable(AnimatedObject, mt)
