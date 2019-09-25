# Animation

This document is a quick walkthrough of the `awesome-AnimationFramework.Animation` module.

This tutorial is a detailed dig down into the `tests/Animation-testrc.lua` script you can find in this repository. I'll try to show you how to use the Animation component. This class is the main core component of the AnimationFramework. This is the object you want to use to compute and control animations.

To run the `tests/Animation-testrc.lua` script and try it by , you should take a look at @{tests.md}.

# Goal

We are trying to animate a wibox. We want it to inflate when the mouse is over it and to go back to it initial size when mouse leave the wibox. This is a simple motion design implementation you can use to create a wibox inflating and collapsing animations.

The wibox's animation is triggered by mouse movements from the awesomewm internal API:

Event|Signal|Action
-|-|-
Mouse enter the wibox|`mouse::enter`|Inflate the wibox
Mouse leave the wibox|`mouse::leave`|Collapse the wibox

## Additional notes

The motion we are creating is inspired from the Google Material Design. We use the `inOutCubic` motion function from the `Tween.lua` library to reproduce the motion Bezier curve. The vertical animation is started with an additional `0.075` second delay but should be finished in time (keep up with animation timing).

# Basics

First, we need to import libraries we will use.

```lua
-- Load awesome wm libraries.
local wibox = require 'wibox'

-- Loading Animation from the awesome-AnimationFramework
local Animation = require 'awesome-AnimationFramework.Animation'
```

Then we create the wibox we want to play with:

```lua
local animationWibox = wibox {
    ontop = true,
    visible = true,
    x = 50,
    y = 50,
    width = 100,
    height = 100
}
```

Signal handling with awesomewm API is easy, we will use the following structure:

```lua
animationWibox:connect_signal('mouse::enter', function ()

    -- CODE FOR THE INFLATING MOTION

end)

animationWibox:connect_signal('mouse::leave', function ()

    -- CODE FOR THE COLLAPSING MOTION

end)
```

# Inflate motion

## Instantiate Animation objects

Every animations we create with the awesome-AnimationFramework is represented by an instance of the Animation object. Because we need different timing for our motion, we need to split the inflate motion into two distinct Animation instances.

```lua
-- First instance: width inflate motion.
local animW = Animation {
    subject = animationWibox, -- The subject of the Animation: Our wibox.
    duration = 0.325, -- The time the Animation will take.
    target = { width = 300 }, -- What is the final state of the Animation.
    easing = 'inOutCubic' -- How the motion will affect subject properties.
}
```

This first instance is the _width inflate motion_. We only specify we want to change our wibox `width` property to `300`.

The second instance, the _height inflate motion_, is slightly the same, but we now use the `height` property:

```lua
-- Second instance: height infalte motion.
local animH = Animation {
    subject = animationWibox,
    duration = 0.25,
    delay = 0.075,
    target = { height = 300 },
    easing = 'inOutCubic'
}
```

You should notice here we changed a little the timings parameters. The animation duration is only `0.25` seconds and we added a delay of `0.075`. With some math, `0.25 + 0.075 = 0.325`, so the total motion time is the same for our two animations. But the height motion will start a little after the width and will go a little faster.

## Play animations

Then we can start our inflate motion by calling the `:startAnimation()` method.

```lua
animW:startAnimation()
animH:startAnimation()
```

Note we could have omitted the `delay` parameter from the `animH` instance. The `:startAnimation` method can take an optional delay parameter:

```lua
-- Exemple of animation started with a delay:
myDelayedAnimH:startAnimation(0.075)
```

## Attache signals

We can also use our Animation instances to attach some signals handling. We will use them here to notify the user what going on under the hood while the width motion is running.

```lua
-- Attach a signal at animation start:
animW:connect_signal('anim::animation_started',
    function (s)
        print('anim stared', s)
    end)

-- Say what happen at each animation update:
animW:connect_signal('anim::animation_updated',
    function (s, delta)
        print('anim updated', s, ' delta=' .. delta)
    end)

-- Notify the animation is finished:
animW:connect_signal('anim::animation_finished',
    function (s)
        print('anim finished', s)
    end)

-- This one should not be called is our exemple.
-- The `anim::animation_stoped` event only happen when you manually call the
-- `:stopAnimation` method.
animW:connect_signal('anim::animation_stoped',
    function (s)
        print('I will never be called cauz the animation is never stopped', s)
    end)
```

Please note the API now support to pass signals handling directly as constructor parameters when instantiating Animation objects. You can use them as following:

```lua
local myAutoSignaledAnimW = Animation {
    subject = animationWibox,
    duration = 0.325,
    target = { width = 300 },
    easing = 'inOutCubic',
    signals = {
        ['anim::animation_started'] = function (s) print('stared', s) end,
        ['anim::animation_updated'] = function (s, delta)
            print('updated', s, ' delta=' .. delta)
        end,
        ['anim::animation_finished'] = function (s) print('finished', s) end
   }
}
```

## Final code

Here is the final code we used on our exemple script:

```lua
animationWibox:connect_signal('mouse::enter', function (c)
    -- Declare our animations.
    local animW = Animation {
        subject = animationWibox,
        duration = 0.325,
        target = { width = 300 },
        easing = 'inOutCubic'
    }
    local animH = Animation {
        subject = animationWibox,
        duration = 0.25,
        delay = 0.075,
        target = { height = 300 },
        easing = 'inOutCubic'
    }

    -- Use signals to notify the user what happen with animW.
    animW:connect_signal('anim::animation_started',
        function (s) print('anim stared', s) end)
    animW:connect_signal('anim::animation_updated',
        function (s, delta) print('anim updated', s, ' delta=' .. delta) end)
    animW:connect_signal('anim::animation_finished',
        function (s) print('anim finished', s) end)
    animW:connect_signal('anim::animation_stoped',
        function (s) print('I will never be called cauz the animation is never stopped', s) end)

    -- Start our animations.
    animW:startAnimation()
    animH:startAnimation()
end)
```

# Collapse motion

The collapse motion is basically the same code code base than the inflate motion. We only need the change some values, like the targeted width and height.

Here is the code we used on our exemple (we used the modern API):

```lua
animationWibox:connect_signal('mouse::leave', function (c)
    -- Collapse height motion:
    Animation {
        subject = animationWibox,
        duration = 0.25,
        delay = 0.075,
        target = { height = 100 },
        easing = 'inOutCubic',
        signals = {
            ['anim::animation_started'] = function (s) print('stared', s) end,
            ['anim::animation_finished'] = function (s) print('finished', s) end
        }
    }:startAnimation()

    -- Collapse width motion:
    Animation {
        subject = animationWibox,
        duration = 0.325,
        target = { height = 100 },
        easing = 'inOutCubic',
        signals = {
            ['anim::animation_started'] = function (s) print('stared', s) end,
            ['anim::animation_finished'] = function (s) print('finished', s) end
        }
    }:startAnimation()
end)
```
