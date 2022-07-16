-- Kirby's Adventure Sprite info viewer
-- 

-- option

local viewmemory = true
local spinfo = true

-- text position
local ofs_x = 152
local ofs_y = 16
local rowlgh = 16
local calmnlgh = 176

-- sprite set
sp_id = {}
sp_xpos = {}
sp_ypos = {}
sp_xpos_c = {}
sp_ypos_c = {}
sp_hbx1 = {}
sp_hbx2 = {}
sp_hby1 = {}
sp_hby2 = {}
sp_exist = {}

--function

gui.clearGraphics()
memory.usememorydomain("System Bus")

function viewmemory()

	Pl_xpos = memory.read_u8(0x0083) + memory.read_u8(0x0095) * 256
	Pl_ypos = memory.read_u8(0x00B9) + memory.read_u8(0x00CB) * 256
	local Pl_xspx = memory.read_u8(0x0071)
	local Pl_yspx = memory.read_u8(0x00A7)
	local Pl_xspd = memory.read_s16_le(0x05B9)
	local Pl_yspd = memory.read_s16_le(0x05BD)
	
	gui.text(ofs_x, ofs_y + rowlgh * 0, "Xpos = " .. Pl_xpos .. "." .. Pl_xspx, 0xffffffff)
	gui.text(ofs_x, ofs_y + rowlgh * 1, "Ypos = " .. Pl_ypos .. "." .. Pl_yspx, 0xffffffff)
	gui.text(ofs_x, ofs_y + rowlgh * 2, "Xspd = " .. Pl_xspd, 0xffffffff)
	gui.text(ofs_x, ofs_y + rowlgh * 3, "Yspd = " .. Pl_yspd, 0xffffffff)
	
end

function spriteinfo()
	
	local Cam_xpos = memory.read_s16_le(0x00DD)
	local Cam_ypos = memory.read_s16_le(0x00E0)
	
	for i = 0, 8 do
		sp_id[i+1] = i
		sp_xpos[i+1] = memory.read_u8(0x008B + i) + memory.read_u8(0x009D + i) * 256
		sp_ypos[i+1] = memory.read_u8(0x00C1 + i) + memory.read_u8(0x00D3 + i) * 256
		
		sp_xpos_c[i+1] = sp_xpos[i+1] - Cam_xpos
		sp_ypos_c[i+1] = sp_ypos[i+1] - Cam_ypos
		
		sp_hbx1[i+1] = -8
		sp_hbx2[i+1] = 8
		sp_hby1[i+1] = -16
		sp_hby2[i+1] = 0
		
		sp_exist[i+1] = memory.read_u8(0x62AB + i)
		
		if sp_exist[i+1] ~= 0x80 then
			gui.drawRectangle(sp_xpos_c[i+1] + sp_hbx1[i+1], sp_ypos_c[i+1] + sp_hby1[i+1], sp_hbx2[i+1] - sp_hbx1[i+1], sp_hby2[i+1]-sp_hby1[i+1], "blue")
		
			gui.pixelText(sp_xpos_c[i+1]-8, sp_ypos_c[i+1], string.format("%X", sp_id[i+1]))
		end
	end
	
	gui.drawRectangle(Pl_xpos - Cam_xpos - 8 ,Pl_ypos - Cam_ypos - 16, 16, 16, "green")
end

-- Main
while true do
	if viewmemory then
		viewmemory()
	end
	if spriteinfo then
		spriteinfo()
	end
	
	emu.frameadvance()
end
