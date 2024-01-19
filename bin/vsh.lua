--[[
    VSH - Vastly Superior sHell
]]

--[[
    TODO
    - completions
    - wildcards
]]

dofile("/lib/shared/easy_color.lua")

local PIPE_BUFFER_SIZE = 1024
local CWD = "/"
local HISTORY_FILE = fs.combine(CWD, ".history")
local CONFIG_FILE = fs.combine(CWD, ".vshrc")

local SEARCH_PATH = {
    "/bin",
    "/usr/bin",
    "/rom/programs"
}

local ALIASES = {
    [ "l" ] = "ls -la"
}

local _TERM = term.native()
-- TODO: replace this with our own subpackage aware implementation
local _MAKE_PACKAGE = dofile("/rom/modules/main/cc/require.lua").make

local history = {}
if fs.exists(HISTORY_FILE) then
    local f = io.open(HISTORY_FILE, "r")
    for line in f:lines() do
        table.insert(history, line)
    end
    f:close()
end

local function t_contains(t, v)
    for i, j in ipairs(t) do
        if j == v then
            return true
        end
    end
    return false
end

local function _error(s)
    print(s)
end

local function get_term()
    -- massive hack to get around weirdly buggy redirect behavior.
    local _term = term.current()
    local t = {}
    for k, v in pairs(_TERM) do
        t[k] = function (...) return rawget(_term, k)(...) end
    end
    return t
end

function parse(s)
    -- taken from https://github.com/cc-tweaked/CC-Tweaked/blob/mc-1.20.x/projects/core/src/main/resources/data/computercraft/lua/rom/programs/shell.lua

    local tWords = {}
    local bQuoted = false
    for match in string.gmatch(s .. "\"", "(.-)\"") do
        if bQuoted then
            table.insert(tWords, match)
        else
            for m in string.gmatch(match, "[^ \t]+") do
                table.insert(tWords, m)
            end
        end
        bQuoted = not bQuoted
    end
    return tWords
end

function expand_aliases(symbol)
    for k, v in pairs(ALIASES) do
        if symbol == k then
            return parse(v)
        end
    end
end

function resolve(path)
    if string.sub(path, 1, 1) == "/" then return path end
    return "/" .. fs.combine(CWD, path)
end

function write_history(command)
    if #history > 0 and history[#history] == command then return end
    local f
    if not fs.exists(HISTORY_FILE) then
        f = fs.open(HISTORY_FILE, "w")
    else
        f = fs.open(HISTORY_FILE, "a")
    end
    f.write(command .. "\n")
    f.close()
    table.insert(history, command)
end

function find_history(command)
    for i = #history, 1, -1 do
        local line = history[i]
        if #line >= #command and string.sub(line, 1, #command) == command then
            return line
        end
    end
    return command
end

function get_history(ind)
    if ind >= #history then
        return ""
    end
    return history[#history-ind]
end

local function find_program(name) 
    local function _e(p, n)
        local p2 = fs.combine(p, n)
        local p3 = p2 .. ".lua"
        if fs.exists(p2) and not fs.isDir(p2) then
            return p2
        elseif fs.exists(p3) and not fs.isDir(p3) then
            return p3
        else
            return false
        end
    end

    local p = _e(CWD, name)
    if p then
        return p
    end

    for i, d in ipairs(SEARCH_PATH) do
        p = _e(d, name)
        if p then
            return p
        end
    end

    return nil
end

local function _execute(pipe, rd, name, ...)

    args = table.pack(...)

    local alias = expand_aliases(name)
    if alias then
        for i, a in ipairs(alias) do
            if i == 1 then
                name = a
            else
                -- janky as shit but works. May want to improve this a bit later
                table.insert(args, 1, a)
            end
        end
    end

    if name == "cd" then
        path = resolve(args[1])
        if not fs.exists(path) then
            _error("cd: no such file or directory: " .. args[1])
            return false
        elseif not fs.isDir(path) then
            _error("cd: not a directory: " .. args[1])
            return false
        else
            CWD = path
            return true
        end
    elseif name == "alias" then
        local alias, expansion = table.unpack(args)
        if not alias then
            for a, e in pairs(ALIASES) do
                print("alias " .. a .. "=" .. e)
            end
            return true
        elseif not expansion then
            local e = ALIASES[alias]
            if not e then
                _error("alias: " .. alias .. "not found")
                return false
            else
                print("alias " .. alias .. "=" .. e)
                return true
            end
        else
            ALIASES[alias] = expansion
            return true
        end
    end

    local program = find_program(name)
    if program == nil then
        _error("Unknown command: " .. name)
        return false
    end
    local _env = setmetatable({
            shell = {
                dir = function () return CWD end,
                getRunningProgram = function () return name end, -- shell.lua compat
                run = function (p) execute_command(parse(p)) end, -- shell.lua compat
                resolve = resolve,
                execute = function (...) execute_command(table.pack(...)) end -- shell.lua compat
            },
            arg = args
        },
        { __index = _G }
    )
    _env.require, _env.package = _MAKE_PACKAGE(_env, CWD)
    -- input redirection
    local rd_f
    if rd then -- from file
        rd_f = io.open(rd, "r")
        _env["read"] = function (...) return rd_f:read(...) end
    elseif not (pipe == "") then -- from pipe
        _env["read"] = function () -- another hack to get pipe input to work
            data = pipe
            pipe = ""
            return data
        end
    end
    fn, err = loadfile(program, nil, _env)
    if fn == nil then
        _error(err)
        if not (rd_f == nil) then rd_f:close() end
        return false
    end

    ok, res = pcall(fn, table.unpack(args))
    if not (rd_f == nil) then rd_f:close() end
    if not ok then
        _error(res)
        return false
    end
    return true
end

function execute_command(tokens)
    local last = 1
    local stop = #tokens
    local pipe = ""
    local rd_in
    local rd_out
    local i = 1
    while i <= #tokens do
        local ct = tokens[i]
        if ct == ">" then
            rd_out = tokens[i+1]
            stop = math.min(i - 1, stop) -- stop parsing arguments here
            i = i + 1 -- skip over argument
        elseif ct == "<" then
            rd_in = tokens[i+1]
            stop = math.min(i - 1, stop)
            i = i + 1
        end
        local _term = get_term()
        local rd_out_f
        if rd_out then
            -- redirect term to file
            rd_out_f = io.open(rd_out, "w")
            _term["write"] = function(...) return rd_out_f:write(...) end
            _term["getSize"] = function () return PIPE_BUFFER_SIZE, 2 end -- our text buffer is infinite, but cc doesn't know how to handle that
            _term["getCursorPos"] = function () return 1, 1 end
            _term["setCursorPos"] = function (x, y) end -- noop to prevent fb corruption
        end
        
        if t_contains({"|", "||", "&&"}, ct) then -- break on operators
            if i == last or i == #tokens then -- operators must follow after a command with at least one argument
                _error("Illegal token " .. ct .. " in position " .. tostring(i))
                return false
            end
            if ct == "|" and not rd_out then
                -- redirect term to pipes
                new_pipe = ""
                _term["write"] = function (s) new_pipe = new_pipe .. s end -- write to pipe
                _term["getSize"] = function () return PIPE_BUFFER_SIZE, 2 end -- our text buffer is infinite, but cc doesn't know how to handle that
                _term["getCursorPos"] = function () return 1, 1 end
                _term["setCursorPos"] = function (x, y) if (y > 1) then new_pipe = new_pipe .. "\n" end end -- newline detection
            end
                
            local old_term = term.redirect(_term)
            local success = _execute(pipe, rd_in, table.unpack(tokens, last, math.min(i-1, stop)))
            term.redirect(old_term)
            pipe = ""

            if rd_out then
                rd_out = nil
                rd_out_f:close()
            elseif ct == "|" and not rd_out then    
                pipe = new_pipe
            elseif ct == "||" then
                if success then
                    return true -- short circuit
                end
            elseif ct == "&&" then
                if not success then
                    return false -- short circuit
                end
            end
            if rd_in then
                rd_in = nil
            end

            last = i+1
            stop = #tokens
        elseif i == #tokens then -- rest of the command
            local old_term = term.redirect(_term)
            local res = _execute(pipe, rd_in, table.unpack(tokens, last, math.min(i, stop)))
            if rd_out then
                rd_out_f:close()
            end
            term.redirect(old_term)
            return res
        end
        i = i + 1
    end
end

function complete()
end

-- init file
if fs.exists(CONFIG_FILE) then
    local f = io.open(CONFIG_FILE, "r")
    for line in f:lines() do
        ok, err = pcall(execute_command, parse(line))
        if not ok then
            _error(err)
        end
    end
    f:close()
end

-- main loop
while true do
    local label = os.getComputerLabel() or tostring(os.getComputerID())
    local w, h = term.getSize()
    write_color(
        colors.lime,
        "root@",
        label,
        colors.white,
        ":",
        colors.blue,
        CWD
    )
    if w < 30 then
        print() -- linebreak on smaller displays (like PDAs)
    end
    term.write("$ ")
    local cmd_string = read(nil, history, nil, nil)
    local cmd = parse(cmd_string)
    execute_command(cmd)
    write_history(cmd_string)
end