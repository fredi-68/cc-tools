dofile("/lib/shared/cli_tools.lua")

parser = ArgumentParser("cp", "copy files and directories")
parser.add_flag("recurse", "r")
parser.add_flag("verbose", "v")
parser.parse()

local function _do_copy(_src, _dst)
    -- copy all files and directories contained in _src to the directory located at _dst
    if fs.isDir(_src) then
        local name = fs.getName(_src)
        if not parser.args.recurse then
            print("cp: -r not specified; omitting directory '" .. name .. "'")
            return
        end
        for i, n in ipairs(fs.list(_src)) do
            local p = fs.combine(_src, n)
            if fs.isDir(p) then
                _do_copy(p, fs.combine(_dst, name))
            else
                _do_copy(p, fs.combine(_dst, n))
            end
        end
    else
        if parser.args.verbose then
            print("cp: '" .. _src .. "' -> '" .. _dst .. "'")
        end
        fs.copy(_src, _dst)
    end
end

local dest = shell.resolve(parser.remaining[#parser.remaining])
for i = 1, #parser.remaining-1 do
    local p = parser.remaining[i]
    p = shell.resolve(p)
    if not fs.exists(p) then
        error("cp: no such file or directory: " .. p)
    end
    _do_copy(p, dest)
end