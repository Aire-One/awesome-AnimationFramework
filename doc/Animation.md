# Animation

A quick documentation of the awesome-AnimationFramework.Animation module.

This demonstration will be a detailed dig down into the `tests.Animation-testrc.lua` script you can find in the repository of the awesome-AnimationFramework project. To run this script, you should take a look at @{tests.md}.

# Goal

We are triing animate a wibox depending on "_mouse focus_" it has. By _"mouse focus"_, understand _"Is the mouse inside the wibox?"_. This is a simple motion design implementation we can implement to create a wibox expending and collapsing animations.

The wibox's animation is trigered by mouse movements from the awesomewm internal API:

- Mouse enter : signal `mouse::enter`,  the wibox expend the wibox ;
- Mouse leave : signla `mouse::leave`, the wibox collapse the wibox.


The motion we are creating is inspired from the Google Material Design. We use the `inOutCubic` motion function from the `Tween.lua` library to reproduice a Bezier curve and the vertical animation is started with an additional `0.075` second delay but should be finished in time.

# Basics

First, we need to import libraries we will use.

```lua
-- load awesome wm libraries
local wibox = require('wibox')

-- Loading the library to test it
-- again, the file should be placed in a directory loaded by awesomewm
local Animation = require('awesome-AnimationFramework.Animation')
```

Then we create a dummy wibox on the screen:

```lua
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
```

Signal handling with awesomewm API is easy, we will use the following structure:

```lua
animationWidget:connect_signal('mouse::enter', function ()

    -- CODE FOR THE EXPENDING ANIMATION

end)

animationWidget:connect_signal('mouse::leave', function ()

    -- CODE FOR THE COLLAPSING ANIMATION

end)
```

# Mouse focus motion: wibox expending animation

```lua
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
```

# Mouse unfocus motion: wibox collapsing animation

We simply do the same than the expending animation... But with differents values to get back to the initial stats of the wibox.

```lua
-- Same logic for collapse transformation on  mouse::leave event
animationWidget:connect_signal('mouse::leave', function (c)
    local animW = Animation(animationWidget, 0.325, { width = 100 }, 'inOutCubic')
    local animH = Animation(animationWidget, 0.325, { height = 100 }, 'inOutCubic')
    animH:startAnimation()
    animW:startAnimation(0.075)
end)
```
