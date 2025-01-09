dofile("/lib/shared/cli_tools.lua")
dofile("/lib/shared/libfat.lua")

parser = ArgumentParser("fat", "fredi_68's archive tools")
parser.add_flag("recurse", "r")
parser.add_flag("extract", "x")
parser.add_flag("append", "a")
parser.add_flag("create", "c")
parser.parse()

local function _append(archive, path)
    if fs.isDir(path) then
        local name = fs.getName(path)
        if not parser.args.recurse then
            print("fat: -r not specified; omitting directory '" .. name .. "'")
            return
        end
        for i, n in ipairs(fs.list(path)) do
            _append(archive, fs.combine(path, n))
        end
    else
        archive.add_to_archive(path)
    end
end

if parser.args.extract then
    Archive(shell.resolve(parser.remaining[1]), "r").extract(parser.remaining[2] or shell.dir())
elseif parser.args.append then
    local archive = Archive(shell.resolve(parser.remaining[1]), "a")
    for i = 2, #parser.remaining do
        _append(archive, parser.remaining[i])
    end
elseif parser.args.create then
    local archive = Archive(shell.resolve(parser.remaining[1]), "w")
    for i = 2, #parser.remaining do
        _append(archive, parser.remaining[i])
    end
else
    error("fat: no operation specified")
end
