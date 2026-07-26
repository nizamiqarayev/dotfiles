--[[
smart-title.lua

Sets force-media-title to the smart title on every file load. This makes
media-title (and therefore anything that reads it -- including webm.lua's
existing %T placeholder) resolve to the smart title, with no changes
needed to webm.lua itself.

In your mpv.conf, use %{media-title} in screenshot-template, e.g.: screenshot-template=%{media-title}-%wH.%wM.%wS.%wT
In your webm.conf, use %T in output_template, e.g.: output_template=%T-%wH.%wM.%wS

Drop in: ~/.config/mpv/scripts/smart-title.lua
--]]

local mp = require("mp")

local function get_smart_title()
    local filename = mp.get_property("filename/no-ext")
    local media_title = mp.get_property("media-title")
    local stream_filename = mp.get_property("stream-open-filename")
    local path = mp.get_property("path")
    local is_ytdl = stream_filename and stream_filename ~= path
    if is_ytdl and media_title and media_title ~= "" then
        return media_title
    end
    return filename
end

mp.register_event("file-loaded", function()
    mp.set_property("force-media-title", get_smart_title())
end)
