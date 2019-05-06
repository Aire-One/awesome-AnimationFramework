# Tests rc.lua

I will here describ how I run my `*-testrc.lua` scripts.

# What's these files?

My `tests/*-testrc.lua` scripts are configurations file you can use to start Awesome WM. However, they are __not__ complete rc files. They relay on your own `rc.lua` at the begining of their execution. I use this hack to only include the code I want to test into these files and still have a working evironment.

That's why these files start with:
```lua
-- require user rc.lua as a base config
-- user rc.lua file should be on a place loaded by awesomewm
require('rc')

...
```

# How do I run them?

I do not run these scripts with a "prodution environment" of Awesome WM. I use Xephyr, an Xorg-Application which can spawn a nested instance of xorg-server to run these file without touching my setup.

I use `awmtt` to easily manage Xephyr. It's a bash script written by [serialoverflow][gh:serialoverflow/awmtt] that helps you test your Awesome configuration files using Xephyr.

I run my own patched version of `awmtt`. You can find it at [https://github.com/Aire-One/awmtt](https://github.com/Aire-One/awmtt) (My patch only fixes a missing space required to chain multiple `-a` to the command).

And here is the script I use to run my  `*-testrc.lua`
```sh
#! /bin/bash

rc_file=$(realpath $1)

awmtt start -B ~/documents/prog/awesome/build/awesome \
    -C $rc_file \
    -s 1600x900 \
    -a '--search /home/aireone/documents/prog/awesome/build/lib' \
    -a '--search /home/aireone/documents/prog/awesome-workspace' \
    -a '--no-argb'
```

Some notes on the awmtt command:

* `-B` : use the awesome binary I build from my awesome wm local git repo clone with the latest paths ;
* `-C` : use this file as the main `rc.lua` entry for awesome ;
* `-a` : passe some parameters to the awesome executable running in Xephyr:
*   * `--search` : add customs directories as libraries for awesome (awesome generated libraries from my clone, and my development directory containing my awesome-AnimationFramework repo) ;
*   * `--no-argb` : don't use alpha chanel (because Xephyr will not run your window compositor).


[gh:serialoverflow/awmtt]:https://github.com/serialoverflow/awmtt
