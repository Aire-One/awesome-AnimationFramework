-- Configuration file for ldoc

project = 'Awesome WM - Animation Framework'
title = 'awesome-AnimationFramework documentation'
description = 'Documentation for the Animation Framework I\'m writing for the Awesome WM!'
full_description = [[
<p>Here is the full documentation of the animation framework I'm developing
for the Awesome WM.</p>
]]

all = true
dir = 'doc'
format='markdown'
pretty = 'lua'
-- prettify_files = true
backtick_references = true
merge = true
use_markdown_titles = true
wrap = true
sort_modules = true

file = {
    'init.lua',
    'Animation.lua',
    'AnimatedObject.lua'
}
