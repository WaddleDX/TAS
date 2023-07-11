--------------------------------------
--	Koro Koro Kirby - lua for TAS	--
--						    v1.0	--
--------------------------------------
-- Author:
--      WaddleDX
-- Works with the following emulators:
--      BizHawk 2.9.1
--      BizHawk 2.9
--      BizHawk 2.8
-- Works with the following cores:
--      Gambatte(SameBoy)

-- ユーザー設定
local POINT_RAD = 2
local POINT_RAD_PREVIOUS = 0.5
local EDGE_MOVE_LIMIT = 68

-- ショートカットキー設定
local TILT_MOVE_UP = "Keypad8"
local TILT_MOVE_DOWN = "Keypad2"
local TILT_MOVE_LEFT = "Keypad4"
local TILT_MOVE_RIGHT = "Keypad6"
local TILT_MOVE_UPLEFT = "Keypad7"
local TILT_MOVE_UPRIGHT = "Keypad9"
local TILT_MOVE_DOWNLEFT = "Keypad1"
local TILT_MOVE_DOWNRIGHT = "Keypad3"
local TILT_MOVE_CENTER = "Keypad5"
local TILT_MOVE_PREVIOUS = "Keypad0"

local TILT_UP_ONE = "Up"
local TILT_DOWN_ONE = "Down"
local TILT_LEFT_ONE = "Left"
local TILT_RIGHT_ONE = "Right"

-- 定数の設定
local OFS_X = 216
local OFS_Y = 12
local ROW_HEIGHT = 16

local EXPADDING_TOP = 64
local EXPADDING_BOTTOM = 64
local EXPADDING_LEFT = 32
local EXPADDING_RIGHT = 220

local TILT_INPUT_PADDING = 20
local AXIS_SIZE = 90

local NON_POP_RANGE = 17

-- ショートカットキーフラグ
local keyMoveUp = {key = TILT_MOVE_UP, current = false, previous = false, pressed = false}
local keyMoveDown = {key = TILT_MOVE_DOWN, current = false, previous = false, pressed = false}
local keyMoveLeft = {key = TILT_MOVE_LEFT, current = false, previous = false, pressed = false}
local keyMoveRight = {key = TILT_MOVE_RIGHT, current = false, previous = false, pressed = false}
local keyMoveUpLeft = {key = TILT_MOVE_UPLEFT, current = false, previous = false, pressed = false}
local keyMoveUpRight = {key = TILT_MOVE_UPRIGHT, current = false, previous = false, pressed = false}
local keyMoveDownLeft = {key = TILT_MOVE_DOWNLEFT, current = false, previous = false, pressed = false}
local keyMoveDownRight = {key = TILT_MOVE_DOWNRIGHT, current = false, previous = false, pressed = false}
local keyMoveCenter = {key = TILT_MOVE_CENTER, current = false, previous = false, pressed = false}
local keyMovePrevious = {key = TILT_MOVE_PREVIOUS, current = false, previous = false, pressed = false}

local keyUpOne = {key = TILT_UP_ONE, current = false, previous = false}
local keyDownOne = {key = TILT_DOWN_ONE, current = false, previous = false}
local keyLeftOne = {key = TILT_LEFT_ONE, current = false, previous = false}
local keyRightOne = {key = TILT_RIGHT_ONE, current = false, previous = false}

-- 入力変数
local tiltX = 0
local tiltY = 0
local tiltX_previous = 0
local tiltY_previous = 0

-- ウィンドウサイズをx2以上に設定（テキストが隠れるので）
if client.getwindowsize() <= 1 then
    client.setwindowsize(2)
end

-- メモリドメインの設定
memory.usememorydomain("System Bus")

----------
-- 関数 --
----------

-- ブール値を文字列に変換
function boolToString(bool)
    local stringValue = bool and "true" or "false"
    return stringValue
end

-- Tilt座標を-90～90に補正
function clampTilt(tilt)
    if tilt < -90 then
        tilt = -90
    elseif tilt > 90 then
        tilt = 90
    end
    return tilt
end

-- ショートカットキーの長押し判定
function isKeyPressed(keyTable, inputTable)
    local input = false
    if inputTable[keyTable["key"]] then
        input = true
    end
    keyTable["current"] = input
    keyTable["pressed"] = keyTable["current"]
    if keyTable["previous"] then
        keyTable["pressed"] = false
    end
    keyTable["previous"] = keyTable["current"]
end

-- ショートカットキーによるTiltの変更
-- 上端に移動
function tiltMoveTop(tiltY, tiltY_previous)
    if movie.isloaded() then
        if tiltY > tiltY_previous + NON_POP_RANGE then
            tiltY = tiltY_previous + NON_POP_RANGE
        elseif tiltY > tiltY_previous - NON_POP_RANGE then
            tiltY = tiltY_previous - NON_POP_RANGE
        else
            tiltY = -EDGE_MOVE_LIMIT
        end
    else
        tiltY = -EDGE_MOVE_LIMIT
    end
    if tiltY < -EDGE_MOVE_LIMIT then
        tiltY = -EDGE_MOVE_LIMIT
    end
    return tiltY
end

-- 左端に移動
function tiltMoveLeftEnd(tiltX)
    tiltX = -EDGE_MOVE_LIMIT
    return tiltX
end

-- 右端に移動
function tiltMoveRightEnd(tiltX)
    tiltX = EDGE_MOVE_LIMIT
    return tiltX
end

-- 下端に移動
function tiltMoveBottom(tiltY, tiltY_previous)
    if movie.isloaded() then
        if tiltY < tiltY_previous - NON_POP_RANGE then
            tiltY = tiltY_previous - NON_POP_RANGE
        elseif tiltY < tiltY_previous + NON_POP_RANGE then
            tiltY = tiltY_previous + NON_POP_RANGE
        else
            tiltY = EDGE_MOVE_LIMIT
        end
    else
        tiltY = EDGE_MOVE_LIMIT
    end
    if tiltY > EDGE_MOVE_LIMIT then
        tiltY = EDGE_MOVE_LIMIT
    end
    return tiltY
end

-- 中心に移動
function tiltMoveCenter(tiltX, tiltY)
    tiltX = 0
    tiltY = 0
    return tiltX, tiltY
end

-- 前フレームのTiltに移動する
function tiltMovePrevious(tiltX, tiltY, tiltX_previous, tiltY_previous)
    if  movie.isloaded() then
        tiltX = tiltX_previous
        tiltY = tiltY_previous
    else
        gui.addmessage("Movie not loaded")
    end
    return tiltX, tiltY
end

-- 上に1移動
function tiltMoveUp(tiltY)
    if tiltY > -90 then
        tiltY = tiltY - 1
    end
    return tiltY
end

-- 左に1移動
function tiltMoveLeft(tiltX)
    if tiltX > -90 then
        tiltX = tiltX - 1
    end
    return tiltX
end

-- 右に1移動
function tiltMoveRight(tiltX)
    if tiltX < 90 then
        tiltX = tiltX + 1
    end
    return tiltX
end

-- 下に1移動
function tiltMoveDown(tiltY)
    if tiltY < 90 then
        tiltY = tiltY + 1
    end
    return tiltY
end

-- Tiltポイントを描画
function drawTilt(tiltAreaX, tiltAreaY, winSize, tiltX, tiltY, pointRad, color)
    local tiltXpos = tiltAreaX + TILT_INPUT_PADDING + 90 + tiltX
    local tiltYpos = tiltAreaY + TILT_INPUT_PADDING + 90 + tiltY
    gui.drawEllipse(tiltXpos - pointRad * winSize, tiltYpos - pointRad * winSize, pointRad * winSize * 2, pointRad * winSize * 2, color, color)
end

-----------------
-- メインループ --
-----------------
while true do
    -- ウィンドウサイズの取得
    local winSize = client.getwindowsize()

    -- GUIの初期化
    gui.cleartext()
    gui.clearGraphics()

    -------------------
    -- メモリ情報表示 --
    -------------------

    -- パディングの設定(int left, int top, int right, int bottom)
    client.SetGameExtraPadding(EXPADDING_LEFT, EXPADDING_TOP, EXPADDING_RIGHT, EXPADDING_BOTTOM)

    -- メモリを取得
    -- 座標系メモリアドレス
    local memory_Xpos = memory.read_s16_be(0xFFA5)
    local memory_Xspx = memory.read_u8(0xFFA7)
    local memory_Zpos = memory.read_s16_be(0xFFA8)
    local memory_Zspx = memory.read_u8(0xFFAA)
    local memory_Ypos = memory.read_s16_be(0xFFAB)
    local memory_Yspx = memory.read_u8(0xFFAD)

    -- 速度系メモリアドレス
    local memory_Xspd = memory.read_s16_be(0xFFD2)
    local memory_Zspd = memory.read_s16_be(0xFFD4)
    local memory_Yspd = memory.read_s16_be(0xFFD6)

    -- その他メモリアドレス
    local stopTime = memory.read_s16_be(0xE28C) -- 止まってる時間

    -- テキスト描画
    -- 座標メモリ表示
    local group1_x = OFS_X + 0
    local group1_y = OFS_Y + 0
    local group1_indent = 24

    local memory_Xpos_db = string.format("%d:%03d", memory_Xpos, memory_Xspx)
    local memory_Zpos_db = string.format("%d:%03d", memory_Zpos, memory_Zspx)
    local memory_Ypos_db = string.format("%d:%03d", memory_Ypos, memory_Yspx)

    gui.text(group1_x, group1_y + ROW_HEIGHT * 0, "- Position -", "white")
    
    gui.text(group1_x, group1_y + ROW_HEIGHT * 1, "X:", "red")
    gui.text(group1_x + group1_indent, group1_y + ROW_HEIGHT * 1, memory_Xpos_db, "white");

    gui.text(group1_x, group1_y + ROW_HEIGHT * 2, "Z:", "blue")
    gui.text(group1_x + group1_indent, group1_y + ROW_HEIGHT * 2, memory_Zpos_db, "white");

    gui.text(group1_x, group1_y + ROW_HEIGHT * 3, "Y:", "green")
    gui.text(group1_x + group1_indent, group1_y + ROW_HEIGHT * 3, memory_Ypos_db, "white");

    -- 速度メモリ表示
    local group2_x = OFS_X + 144
    local group2_y = OFS_Y + 0
    local group2_indent = 24

    gui.text(group2_x, group2_y + ROW_HEIGHT * 0, "- Speed -", "white")
    
    gui.text(group2_x, group2_y + ROW_HEIGHT * 1, "X:", "red")
    gui.text(group2_x + group2_indent, group2_y + ROW_HEIGHT * 1, memory_Xspd, "white");

    gui.text(group2_x, group2_y + ROW_HEIGHT * 2, "Z:", "blue")
    gui.text(group2_x + group2_indent, group2_y + ROW_HEIGHT * 2, memory_Zspd, "white");

    gui.text(group2_x, group2_y + ROW_HEIGHT * 3, "Y:", "green")
    gui.text(group2_x + group2_indent, group2_y + ROW_HEIGHT * 3, memory_Yspd, "white");

    -- その他情報
    local group3_x = OFS_X + 256
    local group3_y = OFS_Y + 0

    gui.text(group3_x, group3_y + ROW_HEIGHT * 0, "- Other -", "white")
    gui.text(group3_x, group3_y + ROW_HEIGHT * 1, "StopTime:", "white")
    gui.text(group3_x + 92, group3_y + ROW_HEIGHT * 1, stopTime, "white");

    -----------------
    -- Tilt入力GUI --
    -----------------

    -- キー入力を取得
    local mouseL = input.getmouse().Left
    
    local inputTable = input.get()
    isKeyPressed(keyMoveUp, inputTable)
    isKeyPressed(keyMoveDown, inputTable)
    isKeyPressed(keyMoveLeft, inputTable)
    isKeyPressed(keyMoveRight, inputTable)
    isKeyPressed(keyMoveUpLeft, inputTable)
    isKeyPressed(keyMoveUpRight, inputTable)
    isKeyPressed(keyMoveDownLeft, inputTable)
    isKeyPressed(keyMoveDownRight, inputTable)
    isKeyPressed(keyMoveCenter, inputTable)
    isKeyPressed(keyMovePrevious, inputTable)

    isKeyPressed(keyUpOne, inputTable)
    isKeyPressed(keyDownOne, inputTable)
    isKeyPressed(keyLeftOne, inputTable)
    isKeyPressed(keyRightOne, inputTable)

    -- Tilt入力エリアの位置を設定
    local tiltAreaX = EXPADDING_LEFT + client.bufferwidth() + EXPADDING_RIGHT - (AXIS_SIZE + TILT_INPUT_PADDING) * 2
    local tiltAreaY = EXPADDING_TOP + client.bufferheight() + EXPADDING_BOTTOM - (AXIS_SIZE + TILT_INPUT_PADDING) * 2

    -- Tiltリミット枠の描画
    gui.drawRectangle(tiltAreaX + TILT_INPUT_PADDING + AXIS_SIZE - EDGE_MOVE_LIMIT, tiltAreaY + TILT_INPUT_PADDING + AXIS_SIZE - EDGE_MOVE_LIMIT, EDGE_MOVE_LIMIT * 2, EDGE_MOVE_LIMIT * 2, "#333333")

    -- 座標軸を描画
    gui.drawAxis(tiltAreaX + TILT_INPUT_PADDING + AXIS_SIZE, tiltAreaY + TILT_INPUT_PADDING + AXIS_SIZE, AXIS_SIZE, "blue")
    
    -- 外枠の描画
    gui.drawRectangle(tiltAreaX + TILT_INPUT_PADDING, tiltAreaY + TILT_INPUT_PADDING, AXIS_SIZE * 2, AXIS_SIZE * 2, "#999999")


    -- マウスクリックを反映
    if mouseL then
        local tiltMouseX = input.getmouse().X - (tiltAreaX - EXPADDING_LEFT + TILT_INPUT_PADDING)
        local tiltMouseY = input.getmouse().Y - (tiltAreaY - EXPADDING_TOP + TILT_INPUT_PADDING)

        if tiltMouseX >= -TILT_INPUT_PADDING and tiltMouseX <= (TILT_INPUT_PADDING + AXIS_SIZE) * 2 then
            if tiltMouseY >= -TILT_INPUT_PADDING and tiltMouseY <= (TILT_INPUT_PADDING + AXIS_SIZE) * 2 then
                        -- tilt座標の更新
                        tiltX = math.floor(tiltMouseX - 90 + 0.5)
                        tiltY = math.floor(tiltMouseY - 90 + 0.5)

                        -- tilt座標を補正
                        tiltX = clampTilt(tiltX)
                        tiltY = clampTilt(tiltY)
            end
        end
    end

    -- ショートカットキーの反映
    if keyMoveUp["pressed"] then
        tiltY = tiltMoveTop(tiltY, tiltY_previous)
    end

    if keyMoveLeft["pressed"] then
        tiltX = tiltMoveLeftEnd(tiltX)
    end

    if keyMoveRight["pressed"] then
        tiltX = tiltMoveRightEnd(tiltX)
    end

    if keyMoveDown["pressed"] then
        tiltY = tiltMoveBottom(tiltY, tiltY_previous)
    end

    if keyMoveUpLeft["pressed"] then
        tiltY = tiltMoveTop(tiltY, tiltY_previous)
        tiltX = tiltMoveLeftEnd(tiltX)
    end

    if keyMoveUpRight["pressed"] then
        tiltY = tiltMoveTop(tiltY, tiltY_previous)
        tiltX = tiltMoveRightEnd(tiltX)
    end

    if keyMoveDownLeft["pressed"] then
        tiltY = tiltMoveBottom(tiltY, tiltY_previous)
        tiltX = tiltMoveLeftEnd(tiltX)
    end

    if keyMoveDownRight["pressed"] then
        tiltY = tiltMoveBottom(tiltY, tiltY_previous)
        tiltX = tiltMoveRightEnd(tiltX)
    end

    if keyMoveCenter["pressed"] then
        tiltX, tiltY = tiltMoveCenter(tiltX, tiltY)
    end

    if keyMovePrevious["pressed"] then
        tiltX, tiltY = tiltMovePrevious(tiltX, tiltY, tiltX_previous, tiltY_previous)
    end

    if keyUpOne["pressed"] then
        tiltY = tiltMoveUp(tiltY)
    end

    if keyLeftOne["pressed"] then
        tiltX = tiltMoveLeft(tiltX)
    end

    if keyRightOne["pressed"] then
        tiltX = tiltMoveRight(tiltX)
    end

    if keyDownOne["pressed"] then
        tiltY = tiltMoveDown(tiltY)
    end

    -- Tilt入力の描画
    drawTilt(tiltAreaX, tiltAreaY, winSize, tiltX, tiltY, POINT_RAD, "#FF6666")

    -- 前フレームのTilt入力を反映（記録中のみ）
    if movie.isloaded() then
        if emu.framecount() >= 1 then
            local inputPrevious = movie.getinput(emu.framecount() - 1)
            tiltX_previous = inputPrevious["Tilt X"]
            tiltY_previous = inputPrevious["Tilt Y"]
            drawTilt(tiltAreaX, tiltAreaY, winSize, tiltX_previous, tiltY_previous, POINT_RAD_PREVIOUS, "#00FF00")

            -- ハネアゲ防止ラインの表示
            local nonPopTopY = tiltAreaY + TILT_INPUT_PADDING + AXIS_SIZE + tiltY_previous - NON_POP_RANGE
            if nonPopTopY < tiltAreaY + TILT_INPUT_PADDING then
                nonPopTopY = tiltAreaY + TILT_INPUT_PADDING
            end

            local nonPopBottomY = tiltAreaY + TILT_INPUT_PADDING + AXIS_SIZE + tiltY_previous + NON_POP_RANGE
            if nonPopBottomY > tiltAreaY + TILT_INPUT_PADDING + AXIS_SIZE * 2  then
                nonPopBottomY = tiltAreaY + TILT_INPUT_PADDING + AXIS_SIZE * 2
            end

            gui.drawLine(tiltAreaX + TILT_INPUT_PADDING, nonPopTopY, tiltAreaX + TILT_INPUT_PADDING + AXIS_SIZE * 2, nonPopTopY, "#006600")

            gui.drawLine(tiltAreaX + TILT_INPUT_PADDING, nonPopBottomY, tiltAreaX + TILT_INPUT_PADDING + AXIS_SIZE * 2, nonPopBottomY, "#006600")
        end
    end

    -- Tilt値をテキスト描画
    gui.text((tiltAreaX + TILT_INPUT_PADDING) * winSize, (tiltAreaY + TILT_INPUT_PADDING) * winSize - 20, "X: " .. tiltX .. " Y: " .. tiltY, "#FF6666")
    if movie.isloaded() then
        gui.text((tiltAreaX + TILT_INPUT_PADDING + (AXIS_SIZE * 2)) * winSize - 128, (tiltAreaY + TILT_INPUT_PADDING) * winSize - 20, "X: " .. tiltX_previous .. " Y: " .. tiltY_previous, "#00FF00")
    end

    -- 入力をBizHawkに反映
    local inputPad = joypad.get()
    inputTable["Tilt X"] = tiltX
    inputTable["Tilt Y"] = tiltY

    joypad.setanalog(inputTable)

    -- ループ処理
    emu.yield()
end