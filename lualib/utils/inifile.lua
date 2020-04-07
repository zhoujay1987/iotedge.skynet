local inifile = {
    _VERSION = "inifile 1.0",
    _DESCRIPTION = "Inifile is a simple, complete ini parser for lua",
    _URL = "http://docs.bartbes.com/inifile",
    _LICENSE = [[
        Copyright 2011-2015 Bart van Strien. All rights reserved.

        Redistribution and use in source and binary forms, with or without modification, are
        permitted provided that the following conditions are met:

           1. Redistributions of source code must retain the above copyright notice, this list of
              conditions and the following disclaimer.

           2. Redistributions in binary form must reproduce the above copyright notice, this list
              of conditions and the following disclaimer in the documentation and/or other materials
              provided with the distribution.

        THIS SOFTWARE IS PROVIDED BY BART VAN STRIEN ''AS IS'' AND ANY EXPRESS OR IMPLIED
        WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
        FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BART VAN STRIEN OR
        CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
        CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
        SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
        ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
        NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
        ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

        The views and conclusions contained in the software and documentation are those of the
        authors and should not be interpreted as representing official policies, either expressed
        or implied, of Bart van Strien.
    ]] -- The above license is known as the Simplified BSD license.
}

local backends = {
    io = {
        write = function(name, contents)
        end,
    },
}

function inifile.parse(name)
    local t = {}
    local section
    local comments = {}
    local sectionorder = {}
    local cursectionorder

    local f = assert(io.open(name))
    for line in f:lines() do

        -- Section headers
        local s = line:match("^%[([^%]]+)%]$")
        if s then
            section = s
            t[section] = t[section] or {}
            cursectionorder = {name = section}
            table.insert(sectionorder, cursectionorder)
        end

        -- Comments
        s = line:match("^;(.+)$")
        if s then
            local commentsection = section or comments
            comments[commentsection] = comments[commentsection] or {}
            table.insert(comments[commentsection], s)
        end

        -- Key-value pairs
        local key, value = line:match("^([%w_]+)%s-=%s-(.+)$")
        if tonumber(value) then value = tonumber(value) end
        if value == "true" then value = true end
        if value == "false" then value = false end
        if key and value ~= nil then
            t[section][key] = value
            table.insert(cursectionorder, key)
        end
    end
    f:close()

    -- Store our metadata in the __inifile field in the metatable
    return setmetatable(t, {
        __inifile = {
            comments = comments,
            sectionorder = sectionorder,
        }
    })
end

function inifile.save(name, t)
    local contents = {}

    -- Get our metadata if it exists
    local metadata = getmetatable(t)
    local comments, sectionorder

    if metadata then metadata = metadata.__inifile end
    if metadata then
        comments = metadata.comments
        sectionorder = metadata.sectionorder
    end

    -- If there are comments before sections,
    -- write them out now
    if comments and comments[comments] then
        for i, v in ipairs(comments[comments]) do
            table.insert(contents, (";%s"):format(v))
        end
        table.insert(contents, "")
    end

    local function writevalue(section, key)
        local value = section[key]
        -- Discard if it doesn't exist (anymore)
        if value == nil then return end
        table.insert(contents, ("%s=%s"):format(key, tostring(value)))
    end

    local function writesection(section, order)
        local s = t[section]
        -- Discard if it doesn't exist (anymore)
        if not s then return end
        table.insert(contents, ("[%s]"):format(section))

        -- Write our comments out again, sadly we have only achieved
        -- section-accuracy so far
        if comments and comments[section] then
            for i, v in ipairs(comments[section]) do
                table.insert(contents, (";%s"):format(v))
            end
        end

        -- Write the key-value pairs with optional order
        local done = {}
        if order then
            for _, v in ipairs(order) do
                done[v] = true
                writevalue(s, v)
            end
        end
        for i, _ in pairs(s) do
            if not done[i] then
                writevalue(s, i)
            end
        end

        -- Newline after the section
        table.insert(contents, "")
    end

    -- Write the sections, with optional order
    local done = {}
    if sectionorder then
        for _, v in ipairs(sectionorder) do
            done[v.name] = true
            writesection(v.name, v)
        end
    end
    -- Write anything that wasn't ordered
    for i, _ in pairs(t) do
        if not done[i] then
            writesection(i)
        end
    end

    local f = assert(io.open(name, "w"))
    f:write(table.concat(contents, "\n"))
    f:close()
end

return inifile
