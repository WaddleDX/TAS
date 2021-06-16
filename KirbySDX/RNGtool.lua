-------------------------------------------------
-- Hoshi no Kirby Super Deluxe(Kirby Super Star)
-- RNG viewer & manipulator for BizHawk
-------------------------------------------------
-- Author: WaddleDX
-- (Calculate RNG module is created by gocha:)
-- https://github.com/gocha/gocha-tas/blob/master/Tools/Lua/kirbysuperstar/random.lua

-- CAUTION:
-- This lua currently only works on the faust core.
-- On other cores, it will cause an error.


------------
---CONFIG---
------------

local RNGtable_checked = true
local RNGgui_checked = true
local Marker_checked = false
local RNGmanipulation_checked = false

--------------------------
--- Calculate RNG module---
--------------------------

local RNG = {}
RNG.__index = RNG

-- Class(...) works as same as Class.new(...)
setmetatable(RNG, {
  __call = function (klass, ...)
    return klass.new(...)
  end,
})

--- Constructs new RNG object.
-- @param seed Initial random seed (corresponding to $3743-3744)
function RNG.new(seed)
  local self = setmetatable({}, RNG)
  self.seed = seed or 0x7777
  return self
end

--- Generates the next random number.
function RNG.advance(self)
  -- Reimplementation of $8aba-8ad1 (part of jsl $8a9f)
  local seed = self.seed
  for i = 1, 11 do
    local randbit = bit.band(1, bit.bxor(1, bit.bxor(seed, bit.bxor(bit.rshift(seed, 1), bit.rshift(seed, 15)))))
    seed = bit.band(bit.bor(bit.lshift(seed, 1), randbit), 0xffff)
  end
  self.seed = seed
end

--- Generates the prev random number.
function RNG.retreat(self)
  local seed = self.seed
  for i = 1, 11 do
    local randbit = bit.band(1, bit.bxor(1, bit.bxor(seed, bit.bxor(bit.rshift(seed, 1), bit.rshift(seed, 2)))))
    seed = bit.band(bit.bor(bit.rshift(seed, 1), bit.lshift(randbit,15)), 0xffff)
  end
  self.seed = seed
end

--- Returns the next random number.
-- @param bound the upper bound (exclusive). Must be between 1 and 255, or 0 (works as 256).
-- @return the next random number.
function RNG.next(self, bound)
  self:advance()

  -- Reimplementation of $8ad7-8ae9 (part of jsl $8a9f)
  local value = bit.band(self.seed, 0xff)
  if bound and bound ~= 0 then
    value = bit.rshift(value * bound, 8)
  end
  return value
end

--- Returns the prev random number.
function RNG.prev(self, bound)
  self:retreat()

  local value = bit.band(self.seed, 0xff)
  if bound and bound ~= 0 then
    value = bit.rshift(value * bound, 8)
  end
  return value
end

-------------------
---Other modules---
-------------------

	-- create RNG table module

	function RNGtable(currng, prev_num, next_num)
		rnglist["mark"] = {}
		
		local rng_main = bit.band(currng, 255)
		rnglist["rng"][prev_num + 1] = rng_main
		
		local calc_prev = RNG.new(currng)
		for i = 1, prev_num do
			rnglist["rng"][prev_num + 1 - i] = calc_prev:prev(0)
		end
		
		local calc_next = RNG.new(currng)
		for i = 1, next_num do
			rnglist["rng"][prev_num + 1 + i] = calc_next:next(0)
		end
		
		-- mark current random number
		rnglist["mark"][prev_num + 1] = "c"
	end
	
	
	-- View RNG module
	
	local txt_ofs_x = 48
	local txt_ofs_y = 16
	local txt_h = 16

	function RNGview(cur_pos, prev, next)
		gui.text(txt_ofs_x, txt_ofs_y, "[RNG]", "cyan", "topright")
		local color = "white"
		local mark = " "
		local idx = 1
		for i = cur_pos - prev, cur_pos + next do
			if rnglist["mark"][i] == "c" then
				color = "cyan"
				mark = "*"
			elseif rnglist["mark"][i] == "m" then
				color = "yellow"
				mark = " "
			else
				color = "white"
				mark = " "
			end
			
			outstr = rnglist["rng"][i]
			gui.text(txt_ofs_x, txt_ofs_y + txt_h * idx, mark .. " " .. string.format("%3d", outstr), color, "topright")
			idx = idx + 1
		end
	end
	
	
	-- RNG gui module
	
	function drawRNG(val, x, wid, col)
		local hgt = val / 8
		gui.drawBox(60+x, 315-hgt, 60+x+wid-1, 315, col, col)
	end

	local scr_w = client.screenwidth() / client.getwindowsize()
	local scr_h = client.screenheight() / client.getwindowsize()

	function RNGgui(cur_pos, prev, next, figw)
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
		local idx = 0
		for i = cur_pos - prev, cur_pos + next do
			if rnglist["mark"][i] == "c" then
				col = "cyan"
			elseif rnglist["mark"][i] == "m" then
				col = "yellow"
			else
				col = "white"
			end
			drawRNG(rnglist["rng"][i], (figw+1) * idx, figw, col)
			idx = idx + 1
		end
	end
	
	
	-- mark RNG module

	function markRNG(cond1, cond2)
		if cond2 < cond1 then
			local temp = cond1
			cond1 = cond2
			cond2 = temp
		end
		
		for i, value in pairs(rnglist["rng"]) do
			if value >= cond1 and value <= cond2 then
				if rnglist["mark"][i] ~= "c" then
					rnglist["mark"][i] = "m"
				end
			end
		end
	end
	
	
	-- Manipulate RNG module

	function writeRNG(rng, num)
		if num <= 0 then
			memory.write_u16_le(0x0743, rng)
		else
			local rng_prev = RNG.new(rng)
			for i = 1, num do
				rng_prev:retreat()
			end
			memory.write_u16_le(0x0743, rng_prev.seed)
		end
	end
	

--------------
---FUNCTION---
--------------

function RNGget()
	local sa1 = "SA1 IRAM"
	if memory.usememorydomain(sa1) == false then
		error("This SNES core is not support " .. sa1 .. ".")
	end
	local random = memory.read_u16_le(0x0743)
	return random
end

function calcGuiLength(cur, figw)
	local lgh = math.ceil(245 / (figw + 1))
	local prev = cur - 1
	local next = lgh - cur
	return prev, next
end

--------------------
---RNG GUI & FORM---
--------------------

--- set extra padding (screen)
client.SetGameExtraPadding(48, 48, 48, 48) 

--- create form
local form = forms.newform(400, 250, "RNG Tool")

--- RNG view field
--- index position
local view_x = 16
local view_y = 16

local view_chkbox1 = forms.checkbox(form, "RNG table")
forms.setsize(view_chkbox1, 80, 16)
forms.setlocation(view_chkbox1, view_x, view_y)
forms.setproperty(view_chkbox1, "Checked", RNGtable_checked)

local view_label1 = forms.label(form, "prev steps:")
forms.setsize(view_label1, 72, 16)
forms.setlocation(view_label1, view_x, view_y + 28)

local view_txtbox1 = forms.textbox(form, "3", 30, 10)
forms.setlocation(view_txtbox1, view_x + 80, view_y + 24)

local view_label2 = forms.label(form, "next steps:")
forms.setsize(view_label2, 72, 16)
forms.setlocation(view_label2, view_x, view_y + 52)

local view_txtbox2 = forms.textbox(form, "32", 30, 10)
forms.setlocation(view_txtbox2, view_x + 80, view_y + 48)

--- RNG gui field
--- index position
local gui_x = 16
local gui_y = 108

local gui_chkbox1 = forms.checkbox(form, "RNG gui")
forms.setsize(gui_chkbox1, 80, 16)
forms.setlocation(gui_chkbox1, gui_x, gui_y)
forms.setproperty(gui_chkbox1, "Checked", RNGgui_checked)

local gui_label1 = forms.label(form, "Reference:")
forms.setsize(gui_label1, 72, 16)
forms.setlocation(gui_label1, gui_x, gui_y + 28)

local gui_txtbox1 = forms.textbox(form, "4", 30, 10)
forms.setlocation(gui_txtbox1, gui_x + 80, gui_y + 24)

local gui_label2 = forms.label(form, "Figure width:")
forms.setsize(gui_label2, 72, 16)
forms.setlocation(gui_label2, gui_x, gui_y + 52)

local gui_txtbox2 = forms.textbox(form, "2", 30, 10)
forms.setlocation(gui_txtbox2, gui_x + 80, gui_y + 48)

--- Marking field
--- index position
local mark_x = 160
local mark_y = 16

local mark_chkbox1 = forms.checkbox(form, "Marker")
forms.setsize(mark_chkbox1, 80, 16)
forms.setlocation(mark_chkbox1, mark_x, mark_y)
forms.setproperty(mark_chkbox1, "Checked", Marker_checked)

local mark_label1 = forms.label(form, "Range to mark:")
forms.setsize(mark_label1, 96, 16)
forms.setlocation(mark_label1, mark_x, mark_y + 28)

local mark_txtbox1 = forms.textbox(form, "0", 30, 10)
forms.setlocation(mark_txtbox1, mark_x + 96, mark_y + 24)

local mark_label2 = forms.label(form, "-")
forms.setsize(mark_label2, 12, 16)
forms.setlocation(mark_label2, mark_x + 128, mark_y + 28)

local mark_txtbox2 = forms.textbox(form, "0", 30, 10)
forms.setlocation(mark_txtbox2, mark_x + 144, mark_y + 24)

--- Manipulator field
--- index position
local mnp_x = 160
local mnp_y = 108

local mnp_chkbox1 = forms.checkbox(form, "RNG manipulation")
forms.setsize(mnp_chkbox1, 120, 16)
forms.setlocation(mnp_chkbox1, mnp_x, mnp_y)
forms.setproperty(mnp_chkbox1, "Checked", RNGmanipulation_checked)

local picturebox1 = forms.pictureBox(form, mnp_x + 16, mnp_y - 20, 120, 16)
local mnp_drawtext1 = forms.drawText(picturebox1, 0, 0, "(CHEAT)", "Red", 0x00000000)

local mnp_label2 = forms.label(form, "Random number:")
forms.setlocation(mnp_label2, mnp_x, mnp_y + 28)

local mnp_txtbox1 = forms.textbox(form, "0", 30, 10)
forms.setlocation(mnp_txtbox1, mnp_x + 100, mnp_y + 24)

local mnp_label3 = forms.label(form, "Steps ahead:")
forms.setlocation(mnp_label3, mnp_x, mnp_y + 52)

local mnp_txtbox2 = forms.textbox(form, "1", 30, 10)
forms.setlocation(mnp_txtbox2, mnp_x + 100, mnp_y + 48)


console.clear()

-- create RNGtable
rnglist = {}
rnglist["rng"] = {}
rnglist["mark"] = {}

-- Main Loop
while true do
	-- set RNG table
	local curRnd = RNGget()
	
	local rng_prev, rng_next = 0, 0
	local view_prev, view_next = 0, 0
	local gui_prev, gui_next = 0, 0
	local mark_cnd1, mark_cnd2 = 0, 0
	
	if forms.ischecked(view_chkbox1) then
		rng_prev = tonumber(forms.gettext(view_txtbox1)) or 0
		rng_next = tonumber(forms.gettext(view_txtbox2)) or 0
		view_prev, view_next = rng_prev, rng_next
	end
	
	if forms.ischecked(gui_chkbox1) then
		gui_ref = tonumber(forms.gettext(gui_txtbox1)) or 1
		gui_figw = tonumber(forms.gettext(gui_txtbox2)) or 0
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
	local cur_pos = rng_prev + 1
	RNGtable(curRnd, rng_prev, rng_next)
	
	-- mark to RNG table
	if forms.ischecked(mark_chkbox1) then
		mark_cnd1 = tonumber(forms.gettext(mark_txtbox1)) or 0
		mark_cnd2 = tonumber(forms.gettext(mark_txtbox2)) or 0
		markRNG(mark_cnd1, mark_cnd2)
	end
	
	-- show RNGview
	if forms.ischecked(view_chkbox1) then
		RNGview(cur_pos, view_prev, view_next)
	end
	
	-- show RNGgui
	if forms.ischecked(gui_chkbox1) then
		RNGgui(cur_pos, gui_prev, gui_next, gui_figw)
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
