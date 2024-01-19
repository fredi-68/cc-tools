src = arg[1]
dst = arg[2]
if src == nil or dst == nil then
    error("mv: must specify source and destination paths")
end
src = shell.resolve(src)
dst = shell.resolve(dst)
fs.move(src, dst)