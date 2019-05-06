# AnimatedObject

A quick documentation of the awesome-AnimationFramework.AnimatedObject module.

This demonstration will be a detailed dig down into the `tests.AnimatedObject-testrc.lua` script you can find in the repository of the awesome-AnimationFramework project. To run this script, you should take a look at @{tests.md}.

You should also take a look at @{Animation.md}. This script is basically the exact same thing but using the more advanced library `AnimatedObject`.

# Basics

First, we need to import libraries we will use.

```lua
-- load awesome wm libraries
local wibox = require('wibox')

-- Loading the library to test it
-- again, the file should be placed in a directory loaded by awesomewm
local AnimObj = require('awesome-AnimationFramework/AnimatedObject')
```

Then we create a dummy wibox on the screen:

```lua
local animationWidget = wibox ({
    ontop = true,
    visible = true,
    opacity = 1,
    x = 50,
    y = 50,
    width = 100,
    height = 100
})
```

Now, we will create an `AnimatedObject` instance with our wibox.

```lua
-- wid is the object we will use now
local wid = AnimObj(animationWidget)
```

The `wid` object is now the widget we will use. It contains both, our wibox and the logics used by the `awesome-AnimationFramework-Animation` library to perform animations.

```lua
-- wid contains your wibox and you still can access it:
wid.subject.width = 300
-- you also can access to all the animations registered for you widget:
print('There are currently ' .. #wid.anims
    .. ' animations registered.')
```

We can connect signals handling to be notified when animations are finished.

```lua
wid:connect_signal('anim::animation_finished', function (s)
    print(s, 'anim finished')
end)
```

# Mouse focus motion

```lua
animationWidget:connect_signal('mouse::enter', function ()
    -- clear all the current animations on wid
    wid:clearAnimations()

    -- Register a new animation
    wid:register_animation {
        target = { width = 300 },
        easing = 'inOutCubic',
        duration = 0.25
    }

    -- you can also get back the Animation object...
    local animH = wid:register_animation {
        target = { height = 300 },
        easing = 'inOutCubic',
        duration = 0.325
    }

    -- ... and use it just like in the previous example:
    -- you can add the delay
    animH.delay = 0.075
    -- or connect its own signals
    animH:connect_signal('anim::animation_started',
        function (s) print('anim stared', s) end)

    -- start all registered animations:
    wid:startAnimations()
end)

animationWidget:connect_signal('mouse::leave', function ()
    wid:clearAnimations()

    wid:register_animation {
        target = { width = 100 },
        easing = 'inOutCubic',
        duration = 0.25,
        delay = 0.075
    }
    wid:register_animation {
        target = { height = 100 },
        easing = 'inOutCubic',
        duration = 0.325
    }

    wid:startAnimations()
end)
```
