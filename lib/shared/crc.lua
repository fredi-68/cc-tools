CRC32_POLY = 0xEDB88320

function CRC32(data, crc)
    if crc == nil then
        crc = 0
    end
    crc = bit.bxor(crc, 0xFFFFFFFF)
    for i = 1, #data do
        crc = bit.bxor(crc, string.byte(data, i))
        for j = 1, 8 do
            if bit.band(crc, 0x1) == 0x1 then
                crc = bit.bxor(bit.brshift(crc, 1), CRC32_POLY)
            else
                crc = bit.brshift(crc, 1)
            end
        end
    end
    return bit.bxor(crc, 0xFFFFFFFF)
end