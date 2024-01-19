dofile("/lib/shared/cli_tools.lua")

parser = ArgumentParser("rm", "remove files and directories")
parser.add_flag("recurse", "r")
parser.add_flag("verbose", "v")
parser.parse()

function _do_rm(path)
    if fs.isDir(path) then
        if not parser.args.recurse then
            return print("rm: -r not specified; omitting directory '" .. fs.getName(path) .. "'")
        end
        for i, p in ipairs(fs.list(path)) do
            _do_rm(fs.combine(path, p))
        end
    end
    if parser.args.verbose then
        print("rm: '" .. path .. "'")
    end
    fs.delete(path)
end

for i = 1, #parser.remaining do
    local p = parser.remaining[i]
    p = shell.resolve(p)
    if not fs.exists(p) then
        error("rm: no such file or directory: " .. p)
    end
    _do_rm(p)
end