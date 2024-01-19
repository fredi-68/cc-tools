dofile("/lib/shared/cli_tools.lua")

parser = ArgumentParser("journalctl", "interact with the ccd system journal")
parser.add_flag("boot", "b", STORE)
parser.add_flag("reverse", "r")
parser.parse()

local path
if parser.args.boot == nil or parser.args.boot == "0" then
    path = libccd.JOURNAL_LOGFILE
elseif parser.args.boot == "-1" then
    path = libccd.JOURNAL_LOGFILE .. ".old"
else
    error("Invalid value for -b: " .. parser.args.boot)
end

local function _log_entry(s)
    print(s)
end

local f = io.open(path, "r")

if parser.args.reverse then
    local lines = {}
    for line in f:lines() do
        table.insert(lines, 1, line)
    end
    for i, line in ipairs(lines) do
        _log_entry(line)
    end
else
    for line in f:lines() do
        _log_entry(line)
    end
end

f:close()