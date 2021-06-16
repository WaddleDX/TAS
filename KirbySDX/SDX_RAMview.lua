--Kirby Super Star Useful Memory Viewer

-- Text Position
local ofs_x = 96
local ofs_y = 8
local rowlgh = 16
local calmnlgh = 176

--Function^\
function viewmemory()
	-- Memory
	memory.usememorydomain("CARTRAM")
	-- 1Player
	local kb_xpos = memory.read_s16_le(0x0988)
	local kb_ypos = memory.read_s16_le(0x0a02)
	local kb_xspx = memory.read_u8(0x0a7d)
	local kb_yspx = memory.read_u8(0x0af7)
	local kb_xspd = memory.read_s16_le(0x16bf)
	local kb_yspd = memory.read_s16_le(0x16c3)

	-- 2Player
	local hp_live = memory.read_s8(0x14a2)

	local hp_xpos = memory.read_s16_le(0x0896)
	local hp_ypos = memory.read_s16_le(0x0910)
	local hp_xspx = memory.read_u8(0x0a7f)
	local hp_yspx = memory.read_u8(0x0af9)
	local hp_xspd = memory.read_s16_le(0x16c1)
	local hp_yspd = memory.read_s16_le(0x16c5)
	
	-- Other
	local boss_hp = memory.read_s16_le(0x17ba)

	-- 1P info
	gui.text(ofs_x, ofs_y, "(1P)", 0xffff0000)
	gui.text(ofs_x, ofs_y + rowlgh * 1, "Xpos = " .. kb_xpos .. "." .. kb_xspx, 0xffffffff)
	gui.text(ofs_x, ofs_y + rowlgh * 2, "Ypos = " .. kb_ypos .. "." .. kb_yspx, 0xffffffff)
	gui.text(ofs_x, ofs_y + rowlgh * 3, "Xspd = " .. kb_xspd, 0xffffffff)
	gui.text(ofs_x, ofs_y + rowlgh * 4, "Yspd = " .. kb_yspd, 0xffffffff)
	
	-- 2P info
	if hp_live < 0 then
		txtcol = 0x66666666
	else
		txtcol = 0
	end
	
	gui.text(ofs_x + calmnlgh, ofs_y, "(2P)", 0xff00ff00 - txtcol)
	gui.text(ofs_x + calmnlgh, ofs_y + rowlgh * 1, "Xpos = " .. hp_xpos .. "." .. hp_xspx, 0xffffffff - txtcol)
	gui.text(ofs_x + calmnlgh, ofs_y + rowlgh * 2, "Ypos = " .. hp_ypos .. "." .. hp_yspx, 0xffffffff - txtcol)
	gui.text(ofs_x + calmnlgh, ofs_y + rowlgh * 3, "Xspd = " .. hp_xspd, 0xffffffff - txtcol)
	gui.text(ofs_x + calmnlgh, ofs_y + rowlgh * 4, "Yspd = " .. hp_yspd, 0xffffffff - txtcol)
	
	-- Other info
	gui.text(ofs_x, ofs_y + rowlgh * 5, "BossHP: " .. boss_hp, 0xffffffff)

end

-- Main
while true do
	viewmemory()
	emu.frameadvance()
end