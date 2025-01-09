src = arg[1]
dst = arg[2]
if src == nil or dst == nil then
    error("mv: must specify source and destination paths")
end
src = shell.resolve(src)
dst = shell.resolve(dst)
if fs.isDir(dst) and not fs.isDir(src) then
    dst = dst .. "/" .. fs.getName(src)
end
fs.move(src, dst)