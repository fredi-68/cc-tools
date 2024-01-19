local pattern = arg[1]
local from_stdin = false
local files = {}
if arg[2] == nil then
    from_stdin = true
else
    for i, f in ipairs(arg) do
        if i == 2 and f == "--" then
            from_stdin = true
            break
        elseif i > 1 then
            if not fs.exists(f) then
                error("grep: no such file: " .. f)
            end
            table.insert(files, f)
        end
    end
end

function process_line(s, pattern)
    if string.match(s, pattern) then
        print(s)
    end
end

function process_file(s, pattern)
    for i, l in ipairs(string.split(s, "\n")) do
        process_line(l, pattern)
    end
end

if from_stdin then
    process_file(read(), pattern)
else
    for i, p in ipairs(files) do
        f = fs.open(p, "r")
        process_file(f)
        f.close()
    end
end