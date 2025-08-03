------------------------------------
-- Kirby Super Star Hitbox Viewer --
------------------------------------
-- Author: WaddleDX
-- Version: 1.0
--    Displays only attack hitboxes for Kirby and helpers.
--    Enemy attacks and main body hitboxes are not yet implemented.
-- 
-- NOTICE:
-- This script only works with the BSNESv115+ or Faust core in BizHawk.
-- It will not function correctly with other SNES cores.
------------------------------------

-- MEMORY DOMAINS
local CARTRAM = "CARTRAM"
local CARTROM = "CARTROM"
local SA1_RAM = "SA1 IRAM"

-- CARTRAM address
local ADDR_PROJ_XPOS = 0x098C
local ADDR_PROJ_YPOS = 0x0A06
local ADDR_PROJ_EXIST = 0x02C2

-- CARTROM address
local ADDR_PROJ_XSIZE = 0x0827FE
local ADDR_PROJ_YSIZE = 0x082842
local ADDR_PROJ_DMG = 0x082886

-- IRAM address
local ADDR_CAM_X = 0x0350
local ADDR_CAM_Y = 0x0055
local ADDR_NORMAL_IDX_KIRBY = 0x040D
local ADDR_NORMAL_IDX_HELPER = 0x0415
local ADDR_PROJ_IDX = 0x05CF

--Function
function getProjectileHitboxInfo(id)
    memory.usememorydomain(CARTROM)
    local x_size = memory.read_u8(ADDR_PROJ_XSIZE + (id))
    local y_size = memory.read_u8(ADDR_PROJ_YSIZE + (id))
    local dmg = memory.read_u8(ADDR_PROJ_DMG + (id))
    return x_size, y_size, dmg
end

function displayHitbox()
    memory.usememorydomain(SA1_RAM)

    -- Get camera position
    local cam_x = memory.read_s16_le(ADDR_CAM_X)
    local cam_y = memory.read_s16_le(ADDR_CAM_Y)
    
    -- Read hitbox data for normal attacks
    local hitbox_atk_normal = {}
    hitbox_atk_normal.kirby = {}
    hitbox_atk_normal.helper = {}

    
    for i = 1, 4 do
        hitbox_atk_normal.kirby[i] = {
            id = memory.read_s16_le(ADDR_NORMAL_IDX_KIRBY - ((i-1) * 0x2)+ 0x00),
            x_pos = memory.read_s16_le(ADDR_NORMAL_IDX_KIRBY - ((i-1) * 0x2) + 0x10),
            y_pos = memory.read_s16_le(ADDR_NORMAL_IDX_KIRBY - ((i-1) * 0x2) + 0x20),
            x_size = memory.read_s16_le(ADDR_NORMAL_IDX_KIRBY - ((i-1) * 0x2) + 0x30),
            y_size = memory.read_s16_le(ADDR_NORMAL_IDX_KIRBY - ((i-1) * 0x2) + 0x40),
            dmg = memory.read_s16_le(ADDR_NORMAL_IDX_KIRBY - ((i-1) * 0x2) + 0x50)
        }
    end

    for i = 1, 4 do
        hitbox_atk_normal.helper[i] = {
            id = memory.read_s16_le(ADDR_NORMAL_IDX_HELPER - ((i-1) * 0x2)+ 0x00),
            x_pos = memory.read_s16_le(ADDR_NORMAL_IDX_HELPER - ((i-1) * 0x2) + 0x10),
            y_pos = memory.read_s16_le(ADDR_NORMAL_IDX_HELPER - ((i-1) * 0x2) + 0x20),
            x_size = memory.read_s16_le(ADDR_NORMAL_IDX_HELPER - ((i-1) * 0x2) + 0x30),
            y_size = memory.read_s16_le(ADDR_NORMAL_IDX_HELPER - ((i-1) * 0x2) + 0x40),
            dmg = memory.read_s16_le(ADDR_NORMAL_IDX_HELPER - ((i-1) * 0x2) + 0x50)
        }
    end

    -- Read hitbox data for projectile attacks
    local hitbox_atk_proj = {}
    for i = 1, 8 do
        memory.usememorydomain(SA1_RAM)
        hitbox_atk_proj[i] = {
            id = memory.read_s16_le(ADDR_PROJ_IDX + ((i-1) * 0x2)),
            exist,
            x_pos,
            y_pos,
            x_size,
            y_size,
            dmg
        }
        -- Read position and size from the cartridge RAM
        memory.usememorydomain(CARTRAM)
        hitbox_atk_proj[i].exist = memory.read_s16_le(ADDR_PROJ_EXIST + (i-1) * 0x2)
        hitbox_atk_proj[i].x_pos = memory.read_s16_le(ADDR_PROJ_XPOS + ((i-1) * 0x2))
        hitbox_atk_proj[i].y_pos = memory.read_s16_le(ADDR_PROJ_YPOS + ((i-1) * 0x2))
        -- Get size and damage from the cartridge ROM
        hitbox_atk_proj[i].x_size, hitbox_atk_proj[i].y_size, hitbox_atk_proj[i].dmg = 
        getProjectileHitboxInfo(hitbox_atk_proj[i].id)
    end

    -- clear the screen
    gui.clearGraphics()

    -- Normal Attack Hitboxes
    for i = 1, 4 do
        local hitbox = hitbox_atk_normal.kirby[i]
        if hitbox.id ~= -1 then
            gui.drawRectangle(
                hitbox.x_pos - cam_x - hitbox.x_size,
                hitbox.y_pos - cam_y - hitbox.y_size,
                hitbox.x_size * 2,
                hitbox.y_size * 2,
                "#FFFF0000",
                "#33FF0000"
            )
            gui.pixelText(
                hitbox.x_pos - cam_x, hitbox.y_pos - cam_y, 
                string.format("dmg=%d", hitbox.dmg), "white", "#33FF0000"
            )
        end
    end
    for i = 1, 4 do
        local hitbox = hitbox_atk_normal.helper[i]
        if hitbox.id ~= -1 then
            gui.drawRectangle(
                hitbox.x_pos - cam_x - hitbox.x_size,
                hitbox.y_pos - cam_y - hitbox.y_size,
                hitbox.x_size * 2,
                hitbox.y_size * 2,
                "#FFFF0000",
                "#33FF0000"
            )
            gui.pixelText(
                hitbox.x_pos - cam_x, hitbox.y_pos - cam_y, 
                string.format("dmg=%d", hitbox.dmg), "white", "#33FF0000"
            )
        end
    end

    -- Projectile Attack Hitboxes
    for i = 1, 8 do
        local hitbox = hitbox_atk_proj[i]
        if hitbox.exist ~= -1 then
            gui.drawRectangle(
                hitbox.x_pos - cam_x - hitbox.x_size,
                hitbox.y_pos - cam_y - hitbox.y_size,
                hitbox.x_size * 2,
                hitbox.y_size * 2,
                "#FF00FF00",
                "#3300FF00"
            )
            gui.pixelText(
                hitbox.x_pos - cam_x, hitbox.y_pos - cam_y, 
                string.format("dmg=%d", hitbox.dmg), "white", "#3300FF00"
            )
        end
    end
end

-- Main
while true do
	displayHitbox()
	emu.frameadvance()

end
