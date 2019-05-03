# Awesome WM - Animation Framework

This repo contains my implementation of a simple animation framework based on
[tween.lua][gh:kikito/tween.lua] for the Awesome WM.

![awesome-AnimationFramework demo][demo]

# Installation

To install the Animation Framework, you only need to clone this repository on
your local config directory.

Note you need to clone it recursively to download tween.lua.

Here is a one-liner shell command to achieve that:
```sh
$ git clone --recurse-submodules https://github.com/Aire-One/awesome-AnimationFramework ~/.config/awesome
```

# Usage

Here are basic examples of usage to create the square inflate animation from
the demo gif.

## Using `Animation.lua` directly

This example use `Animation.lua` directly. It is the easiest way to perform
animations but each animation is a single object you will need to manage
manually.

```lua
local Animation = require('awesome-AnimationFramework/Animation')

-- Material Design involve asymmetric transformations when
-- expending  and collapsing elements.
-- Here is an example of Material Design Animation :

-- The animation will be shown with an empty wibox
local animationWidget = wibox ({
    ontop = true,
    visible = true,
    opacity = 1,
    x = 50,
    y = 50,
    width = 100,
    height = 100
})

-- Expend transformation will occur when mouse::enter event is triggered
animationWidget:connect_signal('mouse::enter', function (c)
    -- An animation is an instance of Animation object.
    -- Material Design Animation for transformations uses a Bezier curve
    -- referred as "ease in out".
    -- (see https://material.io/guidelines/motion/duration-easing.html#duration-easing-natural-easing-curves)
    -- From the tween.lua documentation, "inOutCubic" is the more appropriated
    -- function type to use to copy this motion style.
    local animW = Animation(animationWidget,
        0.325, { width = 300 }, 'inOutCubic')
    local animH = Animation(animationWidget,
        0.325, { height = 300 }, 'inOutCubic')

    -- Once the Animations objects created,
    -- we can start them using :startAnimation method
    animW:startAnimation()

    -- Following Material Design guidelines, we need to add a small delay
    -- to recreate the asymmetric motion movement.
    -- (see https://material.io/guidelines/motion/transforming-material.html#transforming-material-rectangular-transformation)
    animH:startAnimation(0.075)

    -- Use signals to notify what happen with animW
    animW:connect_signal('anim::animation_started',
        function (s) print('anim stared', s) end)
    animW:connect_signal('anim::animation_updated',
        function (s, delta) print('anim updated', s, ' delta=' .. delta) end)
    animW:connect_signal('anim::animation_finished',
        function (s) print('anim finished', s) end)
    animW:connect_signal('anim::animation_stoped',
        function (s) print('I will never be called cauz the animation is never stopped', s) end)
end)

-- Same logic for collapse transformation on  mouse::leave event
animationWidget:connect_signal('mouse::leave', function (c)
    local animW = Animation(animationWidget, 0.325, { width = 100 }, 'inOutCubic')
    local animH = Animation(animationWidget, 0.325, { height = 100 }, 'inOutCubic')
    animH:startAnimation()
    animW:startAnimation(0.075)
end)
```

## Using `AnimatedObject.lua`

In the previous example, you need to manage animations manually. It means you
need to manually call `myAnimation:stopAnimation()` when the mouse leave the
square to properly stop it and prevent a weird animation when quickly move
the mouse in and out of the square. (This is not managed on the example code,
so you can try it and see it by yourself)

Use the `AnimatedObject` wrapper allow you to associate you object (wibox) and
its animations to easily manage them as a single object.

Here is the example of the inflating square using `AnimatedObject.lua`:

```lua
local AnimObj = require('awesome-AnimationFramework/AnimatedObject')

local animationWidget = wibox ({
    ontop = true,
    visible = true,
    opacity = 1,
    x = 50,
    y = 50,
    width = 100,
    height = 100
})

-- wid is the object we will use now
local wid = AnimObj(animationWidget)

-- wid contains your wibox and you still can access it:
wid:object().width = 300
-- you also can access to all the animations registered for you widget:
print('There are currently ' .. wid:animations().length
    .. ' animations registered.')

wid:connect_signal('anim::animation_finished', function (s, anim)
    print(s, 'anim finished', anim)
end)

animationWidget:connect_signal('mouse::enter', function (c)
    -- clear all the current animations on wid
    wid:animations().clear()

    -- you can get back the Animation object...
    local animW = wid:createAnimation({ width = 300 }, 'inOutCubic', 0.325)
    local animH = wid:createAnimation({ height = 300 }, 'inOutCubic', 0.325)

    -- ... and use it just like in the previous example:
    -- you can add the delay
    animH:setStartDelay(0.075)
    -- or connect its own signals
    animW:connect_signal('anim::animation_started',
        function (s) print('anim stared', s) end)

    -- start all registered animations:
    wid:animations().start()
end)

animationWidget:connect_signal('mouse::leave', function (c)
    wid:animations().clear()

    wid:createAnimation({ width = 100 }, 'inOutCubic', 0.325):setStartDelay(0.075)
    wid:createAnimation({ height = 100 }, 'inOutCubic', 0.325)

    wid:animations().start()
end)
```

# Known issues

The main logic of this animation framework lies on the CPU clock system.
That incurs, from what I know, at least two mains issues:
+ every animation frame will cost CPU time to be processed and drawn ;
+ the Linux event loop timer precision is about 20ms, so animations would likely not be 60 FPS.

It means animations could (and will most likely) slow down clients
(understand "opened windows") refresh rate. So, have an heavy usage of this
framework will make you computer seams unresponsive.

Note: From my personal usage, I didn't feel anything for know `¯\_(ツ)_/¯`.
Keep it simple and it should be ok, it depends on your hardware specs.

See [this post from Elv13 on reddit][Elv13-issue-reddit] for more precision.

[gh:kikito/tween.lua]:https://github.com/kikito/tween.lua
[demo]:images/demo.gif
[Elv13-issue-reddit]:https://www.reddit.com/r/awesomewm/comments/8d7l2j/would_you_like_an_animated_wm/dxv7uod
