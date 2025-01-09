dofile("/lib/shared/cls.lua")
dofile("/lib/shared/crc.lua")

Archive = make_class()

function Archive.init(self, path, mode)
    self._f = fs.open(path, mode)
end

function Archive.add_to_archive(self, path)
    local stat = fs.attributes(path)
    local f = fs.open(path, "r")
    local data = f.readAll()
    f.close()
    self._f.write(string.pack(
        "<s2LLLL",
        path,
        #data,
        stat.created,
        stat.modified,
        CRC32(data)
    ))
    self._f.write(data)
end

function Archive.extract(self, path)
    while true do
        local d = self._f.read(2)
        if d == nil then
            break
        end
        local rel_path = self._f.read(string.unpack("<H", d))
        print(rel_path)
        local size, created, modified, checksum = string.unpack("<LLLL", self._f.read(32))
        local data = self._f.read(size)
        local crc = CRC32(data)
        if crc ~= checksum then
            error(rel_path .. ": Invalid data checksum: Expected " .. checksum .. " but was " .. crc)
        end
        local f = fs.open(fs.combine(path, rel_path), "w")
        f.write(data)
        f.close()
    end
end

function Archive.close(self)
    self._f.close()
end