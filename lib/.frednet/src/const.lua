--[[
    rednet is integrated into the CC default bios and cannot be truly disabled.
    This means that in order to avoid unnecessary overhead and invalid rednet
    messages being dispatched, we need to avoid using modem channels also (potentially)
    in use by rednet.

    Rednet uses the following ranges: 
    - 0 ~ 65500     Direct computer addressing
    - 65533         Message repeating
    - 65534         GPS
    - 65535         Broadcast
]]
CHANNEL_IP = 0xffdd
CHANNEL_DHCP = 0xffde
CHANNEL_ARP = 0xffdf
CHANNEL_GPS = 0xffe0
CHANNEL_ANSIBLE = 0xffe1 -- special channel for ender modems, not open by default

ALL_CHANNELS = {
    CHANNEL_IP,
    CHANNEL_DHCP,
    CHANNEL_ARP,
    CHANNEL_GPS
}