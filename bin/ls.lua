--[[
    cc-tools clone of GNU coreutils `ls`.

    Differs in that `ls` without `-h` (or `-l`) will
    always print a simple list view in order
    to make piping easier.
]]

dofile("/lib/shared/better_tabulate.lua")
dofile("/lib/shared/human_readable.lua")
dofile("/lib/shared/cli_tools.lua")

local path

parser = ArgumentParser("ls", "list files")
parser.add_flag("show_all", "a")
parser.add_flag("list_view", "l")
parser.add_flag("human_readable", "h")
parser.parse()

path = parser.remaining[1]

if path == nil then
    path = shell.dir()
else
    path = shell.resolve(path)
    if not fs.exists(path) then
        error("No such path: " .. path)
    end
end

if parser.args.list_view then
    function get_file(p)
        attrs = fs.attributes(p)
        if attrs.isReadOnly then
            mode = "r-"
        else
            mode = "rw"
        end

        if attrs.isDir then
            mode = "d" .. mode
        else
            mode = "-" .. mode
        end

        components = string.split(p, "/")
        name = components[#components]

        local size
        if parser.args.human_readable then
            size = hr_size(attrs.size)
        else
            size = tostring(attrs.size)
        end

        return {mode, size, os.date("%F %R", attrs.modified/1000), name}
    end

    parent = path .. "/.."
    if not fs.exists(parent) then
        parent = path
    end

    if fs.isDir(path) then
        if parser.args.show_all then
            local parent = get_file(parent)
            parent[4] = ".."
            files = {
                get_file(path .. "/."),
                parent
            }
        else
            files = {}
        end

        for i, p in ipairs(fs.list(path)) do
            if parser.args.show_all or not (string.sub(p, 1, 1) == ".") then
                table.insert(files, get_file(path .. "/" .. p))
            end
        end
    else
        files = {get_file(path)}
    end

    tabulate(table.unpack(files))
else -- simple view
    t = {}
    for i, p in ipairs(fs.list(path)) do
        if parser.args.show_all or not (string.sub(p, 1, 1) == ".") then
            if parser.args.human_readable then
                table.insert(t, p)
            else
                print(p)
            end
        end
    end
    if parser.args.human_readable then
        textutils.tabulate(t)
    end
end