-------------------------------------------------
-- Hoshi no Kirby Super Deluxe(Kirby Super Star)
-- RNG viewer & manipulator for BizHawk
-------------------------------------------------
-- Author: WaddleDX

--------------
--- CONFIG ---
--------------
local MEMORY_DONAIN_NAME = "SA1 IRAM"
local ID_FROM_POWERON = true

local RNGTABLE_CHECKED = true
local RNGGUI_CHECKED = true
local MARKER_CHECKED = false
local RNGMANIPULATION_CHECKED = false

local DEFAULT_RNGTABLE_PREVSTEPS = 3
local DEFAULT_RNGTABLE_NEXTSTEPS = 31
local DEFAULT_RNGGUI_REFERENCE = 4
local DEFAULT_RNGGUI_WIDTH = 2

----------------
--- FUNCTION ---
----------------
-- Get Current RNG from Game
function RNGget()
	if memory.usememorydomain(MEMORY_DONAIN_NAME) == false then
			error("The memory domain named " .. MEMORY_DONAIN_NAME .. " is not supported by this core.")
	end
	local random = memory.read_u16_le(0x0743)
	return random
end

-- calculate GUI Length
function calcGuiLength(cur, figw)
	local lgh = math.floor(245 / (figw + 1))
	local prev = cur - 1
	local next = lgh - cur
	return prev, next
end

-- Clamp value to range
function clumpToRange(val, min, max)
	if val < min then
		val = min
	elseif val > max then
		val = max
	end
	return val
end

-- Wrap value in range
function wrapValueInRange(val, min, max)
	local range = max - min + 1
	while val < min do
		val = val + range
	end
	while val > max do
		val = val - range
	end
	return val
end

---------------------
--- Other modules ---
---------------------
-- View RNG Count
function RNGcountView(Count)
	local RNGCntOffsetX = 48
	local RNGCntOffsetY = 16
	if ID_FROM_POWERON then
		Count = Count - 15687
		Count = wrapValueInRange(Count, 0, 65533)
	end
	gui.text(RNGCntOffsetX, RNGCntOffsetY, "ID: " .. Count, "cyan", "topright")
end

-- View RNG module
function RNGview(view_prev, view_next, mark_ref, Rcnt)
	local txt_ofs_x = 48
	local txt_ofs_y = 48
	local txt_h = 16
	gui.text(txt_ofs_x, txt_ofs_y, "[RNG]", "cyan", "topright")
	local color = "white"
	local mark = " "
	local index = 1
	for i = -view_prev, view_next do
		if markTable[i + mark_ref] == "cur" then
			color = "cyan"
			mark = "*"
		elseif markTable[i + mark_ref] == "mark" then
			color = "yellow"
			mark = " "
		else
			color = "white"
			mark = " "
		end
		
		local cnt = wrapValueInRange(Rcnt + i + 1, 1, 65534)
		local outstr = rnglist["RNGtable"]["RNG1"][cnt]
		gui.text(txt_ofs_x, txt_ofs_y + txt_h * index, mark .. " " .. string.format("%3d", outstr), color, "topright")
		index = index + 1
	end
end

-- RNG gui module
function drawRNG(val, x, wid, col)
	local hgt = val / 8
	gui.drawBox(60 + x, 315 - hgt, 60 + x + wid - 1, 315, col, col)
end

local scr_w = client.screenwidth() / client.getwindowsize()
local scr_h = client.screenheight() / client.getwindowsize()

function RNGgui(gui_prev, gui_next, figw, mark_ref, Rcnt)
	gui.defaultPixelFont("gens")
	gui.drawBox(48, 273, 304, 319, "white", 0x99000000)
	gui.pixelText(61, 275, "RNG GUI", 0x80ffffff)
	gui.pixelText(49, 280, "FF")
	gui.pixelText(49, 296, "80")
	gui.pixelText(49, 312, "00")
	
	gui.drawLine(58, 274, 58, 319)
	gui.drawLine(59, 283, 304, 283, 0x80ffffff)
	gui.drawLine(59, 291, 304, 291, 0x80ffffff)
	gui.drawLine(59, 299, 304, 299, 0x80ffffff)
	gui.drawLine(59, 307, 304, 307, 0x80ffffff)
	gui.drawLine(59, 315, 304, 315, 0x80ffffff)
	
	local col = "white"
	local index = 0
	for i = -gui_prev, gui_next do
		if markTable[i + mark_ref] == "cur" then
			col = "cyan"
		elseif markTable[i + mark_ref] == "mark" then
			col = "yellow"
		else
			col = "white"
		end
		local Cnt = wrapValueInRange(Rcnt + i + 1, 1, 65534)
		local val = rnglist["RNGtable"]["RNG1"][Cnt]
		drawRNG(val, (figw + 1) * index, figw, col)
		index = index + 1
	end
end

-- mark RNG module
function markRNG(min, max, divisor, rng_prev, rng_next, Rcnt)
	if max < min then
		local temp = min
		min = max
		max = temp
	end
	if divisor <= 0 then
		divisor = 256
	end
	local index = 1
	for i = -rng_prev, rng_next do
		local Cnt = wrapValueInRange(Rcnt + i + 1, 1, 65534)
		local val = rnglist["RNGtable"]["RNG1"][Cnt]
		val = val % divisor

		if val >= min and val <= max then
			if markTable[index] ~= "cur" then
				markTable[index] = "mark"
			end
		end
		index = index + 1
	end
end

-- Manipulate RNG module
function writeRNG(rng, num)
	rng = clumpToRange(rng, 0, 65535)
	if num <= 0 then
		memory.write_u16_le(0x0743, rng)
	else
		local prevCnt = rnglist["RNGtoCnt"][rng + 1] + 1 - num
		prevCnt = wrapValueInRange(prevCnt, 1, 65534)
		local rng_prev = rnglist["RNGtable"]["RNG1"][prevCnt] + rnglist["RNGtable"]["RNG2"][prevCnt] * 256
		memory.write_u16_le(0x0743, rng_prev)
	end
end

--------------------
--- RNG Database ---
--------------------
-- Open RNG DB file
local dbfile = "RNG.db"
local message = SQL.opendatabase(dbfile)
console.writeline(message)

-- create RNGtable
rnglist = {}
rnglist["RNGtable"] = {}
rnglist["RNGtable"]["RNG1"] = {}
rnglist["RNGtable"]["RNG2"] = {}
rnglist["RNGtoCnt"] = {}

local t_rng = SQL.readcommand("SELECT RNG1, RNG2 FROM RNGtable")
for i = 1, 65534 do
	rnglist["RNGtable"]["RNG1"][i] = t_rng["RNG1 " .. i-1]
	rnglist["RNGtable"]["RNG2"][i] = t_rng["RNG2 " .. i-1]
end

local t_rngToCnt = SQL.readcommand("SELECT Count FROM RNGtoCnt")
for i=1, 65536 do
	rnglist["RNGtoCnt"][i] = t_rngToCnt["Count " .. i-1]
end

----------------------
--- RNG GUI & FORM ---
----------------------
--- set extra padding (screen)
client.SetGameExtraPadding(48, 48, 48, 48) 

--- create form
-- destroy forms
forms.destroyall()
form = forms.newform(400, 250, "RNG Tool")

--- RNG view field
--- index position
local view_x = 16
local view_y = 16

local view_chkbox1 = forms.checkbox(form, "RNG table")
forms.setsize(view_chkbox1, 80, 16)
forms.setlocation(view_chkbox1, view_x, view_y)
forms.setproperty(view_chkbox1, "Checked", RNGTABLE_CHECKED)

local view_label1 = forms.label(form, "Prev steps:")
forms.setsize(view_label1, 72, 16)
forms.setlocation(view_label1, view_x, view_y + 28)

local view_txtbox1 = forms.textbox(form, tostring(DEFAULT_RNGTABLE_PREVSTEPS), 30, 10)
forms.setlocation(view_txtbox1, view_x + 80, view_y + 24)

local view_label2 = forms.label(form, "Next steps:")
forms.setsize(view_label2, 72, 16)
forms.setlocation(view_label2, view_x, view_y + 52)

local view_txtbox2 = forms.textbox(form, tostring(DEFAULT_RNGTABLE_NEXTSTEPS), 30, 10)
forms.setlocation(view_txtbox2, view_x + 80, view_y + 48)

--- RNG gui field
--- index position
local gui_x = 16
local gui_y = 108

local gui_chkbox1 = forms.checkbox(form, "RNG gui")
forms.setsize(gui_chkbox1, 80, 16)
forms.setlocation(gui_chkbox1, gui_x, gui_y)
forms.setproperty(gui_chkbox1, "Checked", RNGGUI_CHECKED)

local gui_label1 = forms.label(form, "Reference:")
forms.setsize(gui_label1, 72, 16)
forms.setlocation(gui_label1, gui_x, gui_y + 28)

local gui_txtbox1 = forms.textbox(form, tostring(DEFAULT_RNGGUI_REFERENCE), 30, 10)
forms.setlocation(gui_txtbox1, gui_x + 80, gui_y + 24)

local gui_label2 = forms.label(form, "Bar width:")
forms.setsize(gui_label2, 72, 16)
forms.setlocation(gui_label2, gui_x, gui_y + 52)

local gui_txtbox2 = forms.textbox(form, tostring(DEFAULT_RNGGUI_WIDTH), 30, 10)
forms.setlocation(gui_txtbox2, gui_x + 80, gui_y + 48)

--- Marking field
--- index position
local mark_x = 160
local mark_y = 16

local mark_chkbox1 = forms.checkbox(form, "Marker")
forms.setsize(mark_chkbox1, 80, 16)
forms.setlocation(mark_chkbox1, mark_x, mark_y)
forms.setproperty(mark_chkbox1, "Checked", MARKER_CHECKED)

local mark_label1 = forms.label(form, "Between:")
forms.setsize(mark_label1, 96, 16)
forms.setlocation(mark_label1, mark_x, mark_y + 28)

local mark_txtbox1 = forms.textbox(form, "0", 30, 10)
forms.setlocation(mark_txtbox1, mark_x + 96, mark_y + 24)

local mark_label2 = forms.label(form, "-")
forms.setsize(mark_label2, 12, 16)
forms.setlocation(mark_label2, mark_x + 128, mark_y + 28)

local mark_txtbox2 = forms.textbox(form, "0", 30, 10)
forms.setlocation(mark_txtbox2, mark_x + 144, mark_y + 24)

local mark_label3 = forms.label(form, "Divisor:")
forms.setsize(mark_label3, 96, 16)
forms.setlocation(mark_label3, mark_x, mark_y + 52)

local mark_txtbox3 = forms.textbox(form, "256", 30, 10)
forms.setlocation(mark_txtbox3, mark_x + 96, mark_y + 48)

--- Manipulator field
--- index position
local mnp_x = 160
local mnp_y = 108

local mnp_chkbox1 = forms.checkbox(form, "RNG manipulation")
forms.setsize(mnp_chkbox1, 120, 16)
forms.setlocation(mnp_chkbox1, mnp_x, mnp_y)
forms.setproperty(mnp_chkbox1, "Checked", RNGMANIPULATION_CHECKED)

local picturebox1 = forms.pictureBox(form, mnp_x + 16, mnp_y - 20, 120, 16)
local mnp_drawtext1 = forms.drawText(picturebox1, 0, 0, "** CHEAT **", "Red", 0x00000000)

local mnp_label2 = forms.label(form, "Random number:")
forms.setlocation(mnp_label2, mnp_x, mnp_y + 28)

local mnp_txtbox1 = forms.textbox(form, "0", 30, 10)
forms.setlocation(mnp_txtbox1, mnp_x + 100, mnp_y + 24)

local mnp_label3 = forms.label(form, "Steps ahead:")
forms.setlocation(mnp_label3, mnp_x, mnp_y + 52)

local mnp_txtbox2 = forms.textbox(form, "1", 30, 10)
forms.setlocation(mnp_txtbox2, mnp_x + 100, mnp_y + 48)

-----------
-- SETUP --
-----------
console.clear()

---------------
-- MAIN LOOP --
---------------
while true do
	-- set RNG table
	local curRnd = RNGget()
	local Rcnt = rnglist["RNGtoCnt"][curRnd + 1]
	
	local rng_prev, rng_next = 0, 0
	local view_prev, view_next = 0, 0
	local gui_prev, gui_next = 0, 0
	local gui_ref, gui_figw = 0, 0
	local mark_ref = 0
	
	if forms.ischecked(view_chkbox1) then
		rng_prev = tonumber(forms.gettext(view_txtbox1)) or 0
		rng_next = tonumber(forms.gettext(view_txtbox2)) or 0
		rng_prev = clumpToRange(rng_prev, 0, 255)
		rng_next = clumpToRange(rng_next, 0, 255)
		view_prev, view_next = rng_prev, rng_next
	end
	
	if forms.ischecked(gui_chkbox1) then
		gui_ref = tonumber(forms.gettext(gui_txtbox1)) or 1
		gui_figw = tonumber(forms.gettext(gui_txtbox2)) or 1
		if gui_figw < 1 then
			gui_figw = 1
		end
		gui_prev, gui_next = calcGuiLength(gui_ref, gui_figw)
		if gui_prev > rng_prev then
			rng_prev = gui_prev
		end
		if gui_next > rng_next then
			rng_next = gui_next
		end
	end

	-- mark current rng
	markTable = {}
	mark_ref = rng_prev + 1
	markTable[mark_ref] = "cur"
	
	-- mark to RNG table
	if forms.ischecked(mark_chkbox1) then
		local mark_val1 = tonumber(forms.gettext(mark_txtbox1)) or 0
		local mark_val2 = tonumber(forms.gettext(mark_txtbox2)) or 0
		local mark_div = tonumber(forms.gettext(mark_txtbox3)) or 256
		markRNG(mark_val1, mark_val2, mark_div, rng_prev, rng_next, Rcnt)
	end

	-- show RNGCount
	RNGcountView(Rcnt)
	
	-- show RNGview
	if forms.ischecked(view_chkbox1) then
		RNGview(view_prev, view_next, mark_ref, Rcnt)
	end

	-- show RNGgui
	if forms.ischecked(gui_chkbox1) then
		RNGgui(gui_prev, gui_next, gui_figw, mark_ref, Rcnt)
	else
		gui.clearGraphics()
	end
	
	-- RNG manipulator
	if forms.ischecked(mnp_chkbox1) then
		local rng = tonumber(forms.gettext(mnp_txtbox1)) or 0
		local step = tonumber(forms.gettext(mnp_txtbox2)) or 0
		writeRNG(rng, step)
	end
	emu.frameadvance()
end
