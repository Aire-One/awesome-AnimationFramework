-- Configuration file for ldoc

project = 'Awesome WM - Animation Framework'
title = 'awesome-AnimationFramework documentation'
description = 'Documentation for the Animation Framework I\'m writing for the Awesome WM!'
full_description = [[
<p>Here is the full documentation of the animation framework I'm developing
for the Awesome WM.</p>
<p>To learn more about this framework, you should take a look at the @{README.md} file.</p>
]]

all = false
dir = '../build/doc'
format='markdown'
pretty = 'lua'
-- prettify_files = true
backtick_references = true
merge = true
use_markdown_titles = true
wrap = true
sort_modules = true

kind_names = { topic = 'Documentation', module = 'Modules' }

topics = {
    '../README.md',
    'tests.md',
    'Animation.md',
    'AnimatedObject.md'
}

file = {
    '../Animation.lua',
    '../AnimatedObject.lua'
}

-- Define some new ldoc tags from the AwesomeWM doc
new_type("function", "Functions") -- Hack to get funcion on top
new_type("method", "Object methods", false, "param")
new_type("property", "Object properties", false, "Type")
new_type("signal", "Signals", false, "Arguments")
new_type("deprecated", "Deprecated functions", false, "param")
new_type("deprecatedproperty", "Deprecated Object properties", false, "Type")
