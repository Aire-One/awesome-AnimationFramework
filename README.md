# Awesome WM - Animation Framework

This repo contains my implementation of a simple animation framework based on [tween.lua][gh:kikito/tween.lua] for the Awesome WM.

![awesome-AnimationFramework demo][demo]

# Installation

To install the Animation Framework, you only need to clone this repository on your local config directory.

Note you need to clone it recursively to download tween.lua.

Here is a one-liner shell command to achieve that:

```sh
$ git clone --recurse-submodules https://github.com/Aire-One/awesome-AnimationFramework ~/.config/awesome
```

# Documentation

You can generate API documentation with ldoc. The `doc/generate_doc.sh` script will build the complete documentation site into `build/doc` directory (you should run this script from the project root).

```sh
. doc/generate_doc.sh
```

To understand how the AnimationFramework works, you can read the [Animation guide][guide] and examples from the `tests` directory.

# Known issues

The main logic of this animation framework lies on the CPU clock system. That incurs, from what I know, at least two mains issues:

- every animation frame will cost CPU time to be processed and drawn ;
- the Linux event loop timer precision is about 20ms, so animations would not likely be 60 FPS.

It means animations could (and will most likely) slow down clients (understand "opened windows") refresh rate. So, have an heavy usage of this framework will make you computer seams unresponsive.

Note: From my personal usage, I didn't feel anything for know `¯\_(ツ)_/¯`. Keep it simple and it should be ok, it depends on your hardware specs.

See [this post from Elv13 on reddit][Elv13-issue-reddit] for more precision.

[gh:kikito/tween.lua]:https://github.com/kikito/tween.lua
[demo]:images/demo.gif
[guide]:doc/Animation.md
[Elv13-issue-reddit]:https://www.reddit.com/r/awesomewm/comments/8d7l2j/would_you_like_an_animated_wm/dxv7uod
