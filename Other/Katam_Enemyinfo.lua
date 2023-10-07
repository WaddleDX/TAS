--================================================
-- Kirby Amazing Mirror                         --
-- Enemy Info Viewer for mGBA                   --
-- Version 1.1                                  --
-- Author: WaddleDX                             --
--================================================
-- Some of the code has been adapted and        --
-- modified from scripts created in the past:   --
-- https://pastebin.com/X5WwaB2d                --
--================================================

-- Preset
local NAME_LANGUAGE = "JA" -- EN or JA
local SHEEK_RANGE = 0x17FF -- MAX 0x36FF

local nameLength = 30
if nameLength == "JA" then
    nameLength = 15
end

-- create text buffer
enemyInfo = console:createBuffer("EnemyInfo")

-- Enemy NameSet
enemyName = {}
enemyName["JA"] = 
{"ワドルディ","ブロントバート","ブリッパー","グランク","スクイッシー","スカーフィ","ゴルドー","ビルゲ","チップ","ソアラ","ハリー","コロロン","アニー","ブロックン","ビルゲ（怒り）","リープ","ジャック","ビッグワドルディ","ワドルドゥ","* UNKNOWN *","ホットヘッド","レーザーボール","ペンギー","ロッキー","サーキブル","スパーキー","ソードナイト","ユーフォー","ツイスター","ウィリー","ノディ","ガレブ（茶）","ガレブ（黄）","ガレブ（灰）","フォーリー","シューティ","スカーフィ（怒り）","デッシー","コックン","ミニー","ボンバー","ヘビーナイト","ジャイアントロッキー","メタルガーディアン","ストッピー（未使用）","バッティー","フォーリー（落下）","ドッコーン","クラッシュボム（DM）","* UNKNOWN *","ドロッピー","プランク","ミラン","* UNKNOWN *","* UNKNOWN *","ワドルディ（ボス）","Mr.フロスティ","ボンカース","ファンファン","バタファイア","バウファイター","ボクシィ","マスターハンド","エアロスター","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","クラッコ","キングゴーレム","マスターハンド（大ボス）","ガブリエル","ウィズ","モーリィ","メガタイタン","タイタンヘッド","クレイジーハンド","ダークメタナイト","ダークマインド（第一形態）","ダークマインド（第二形態）","ダークマインド（最終戦）","？？？（ダークメタナイト）","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","食べ物","元気ドリンク","骨付き肉","マキシムトマト","電池","1UP","無敵キャンディ","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","強風","* UNKNOWN *","コピーのもと1","コピーのもと2","コピーのもと3","コピーのもと4","* UNKNOWN *","* UNKNOWN *","マスター（台座）","* UNKNOWN *","* UNKNOWN *","岩（キングゴーレム）","ゴルドー（キングゴーレム）","葉（フォーリー）","フライパン（コックン）","パクリエル","* UNKNOWN *","火炎弾（バタファイア）","パラソル","能力星","能力星（マスター）","星（ボス戦用）","氷（フロスティ）","大きい氷（フロスティ）","ヤシの実（ボンカース）","大きいヤシの実（ボンカース）","* UNKNOWN *","火の玉（プランク）","氷（プランク）","爆弾（プランク／ボクシィ）","フライパン（プランク）","バナナの皮（プランク）","プレゼント（ボクシィ）","* UNKNOWN *","爆弾（エアロスター）","ミサイル（エアロスター）","気攻弾（バウファイター）","ラグビーボール（ウィズ）","自動車（ウィズ）","風船（ウィズ）","爆弾（ウィズ）","カミナリ雲（ウィズ）","毒リンゴ（ウィズ）","ドロッピー（ウィズ）","左上腕（メガタイタン）","左下腕（メガタイタン）","右上腕（メガタイタン）","右下腕（メガタイタン）","ミサイル（タイタンヘッド）","小岩（モーリィ）","ネジ（モーリィ）","タイヤ（モーリィ）","爆弾（モーリィ）","大岩（モーリィ）","ダイナマイト（モーリィ）","トゲ鉄球（モーリィ）","指鉄砲（マスターハンド）","* UNKNOWN *","鏡（DM1）","スターパレット・赤（DM1）","スターパレット・青（DM1）","スターパレット・紫（DM1）","スターパレット・緑（DM1）","* UNKNOWN *","鏡（DM2）","ダークレーザー（DM2）","ダークビーム（DM2）","鏡の破片（DM2）","スターパレット（DM3）","カッター（サーキブル）","弾（グランク）","弾（シャッツォ）","矢（アニー）","弾（ジャック）","爆弾（シューティ）","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *"}0
enemyName["EN"] = 
{"Waddle Dee","Bronto Burt","Blipper","Glunk","Squishy","Scarfy","Gordo","Snooter","Chip","Soarar","Haley","Roly-Poly","Cupie","Blockin","Snooter (anger)","Leap","Jack","Big Waddle Dee","Waddle Doo","* UNKNOWN *","Hot Head","Laser Ball","Pengy","Rocky","Sir Kibble","Sparky","Sword Knight","UFO","Twister","Wheelie","Noddy","Golem (brown)","Golem (yellow)","Golem (gray)","Foley","Shooty","Scarfy (anger)","Boxin","Cookin","Minny","Bomber","Heavy Knight","Giant Rocky","Metal Guardian","Stoppy (UNUSED)","Batty","Foley (falling)","Bang-Bang","Crash bomb (DM)","* UNKNOWN *","Droppy","Prank","Mirra","* UNKNOWN *","* UNKNOWN *","Waddle Dee (Boss)","Mr. Frosty","Bonkers","Phan Phan","Batafire","Box Boxer","Boxy","Master Hand","Bombar","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","Kracko","King Golem","Master Hand(Area Boss)","Gobbler","Wiz","Moley","Mega Titan","Titan Head","Crazy Hand","Dark Meta Knight","Dark Mind (Phase1)","Dark Mind (Phase2)","Dark Mind (Final)","??? (Dark Meta Knight)","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","Food","Energy Drink","Chicken","Maxim Tomato","Battery","1UP","Invincible Candy","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","Strong wind","* UNKNOWN *","Copy Essence - 1","Copy Essence - 2","Copy Essence - 3","Copy Essence - 4","* UNKNOWN *","* UNKNOWN *","Master (pedestal)","* UNKNOWN *","* UNKNOWN *","Rock (King Golem)","Gordo (King Golem)","Leaf (Foley)","Frying pan (Cookin)","Snapper","* UNKNOWN *","Flame bomb (Batafire)","Parasol","Ability star","Ability star (Master)","Star (by Boss)","Ice (Frosty)","Large ice (Frosty)","Palm fruit (Bonkers)","Large palm fruit (Bonkers)","* UNKNOWN *","Fire ball (Prank)","Ice (Prank)","Bomb (Prank / Boxy)","Fried pan (Prank)","Banana skin (Prank)","Gift box (Boxy)","* UNKNOWN *","Bomb (Bombar)","Missile (Bombar)","Airy bullet (Box Boxer)","Rugby ball (Wiz)","Car (Wiz)","Balloon (Wiz)","Bomb (Wiz)","Thunder cloud (Wiz)","Poison apple (Wiz)","Droppy (Wiz)","Upper-left arm (Mega Titan)","Lower-left arm (Mega Titan)","Upper-right arm (Mega Titan)","Lower-right arm (Mega Titan)","Missile (Titan Head)","Small rock (Moley)","Screw (Moley)","Tire (Moley)","Bomb (Moley)","Large rock (Moley)","Dynamite (Moley)","Spike ball (Moley)","Finger bullet (Master Hand)","* UNKNOWN *","Mirror (DM1)","Red Star Palette  (DM1)","Blue Star Palette (DM1)","Purple Star Palette (DM1)","Green Star Palette (DM1)","* UNKNOWN *","Mirror (DM2)","Dark laser (DM2)","Dark beam (DM2)","Mirror debris (DM2)","Star Palette (DM3)","Cutter (Sir Kibble)","Bullet (Glunk)","Bullet (Shotzo)","Arrow (Cupie)","Bullet (Jack)","Bomb (Shooty)","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *","* UNKNOWN *"}

-- function
function updateEnemies()
	local count=1
	local address=0x0
	local found=false
	local end_address=SHEEK_RANGE
    Enemies = {}
	
	while address < end_address do		
		if emu.memory.wram:read8(address)>= 0xFE
        and emu.memory.wram:read8(address+1)== 0xFF
        and emu.memory.wram:read8(address+2)== 0xFF
        and emu.memory.wram:read8(address+3)== 0x01
		and emu.memory.wram:read8(address-1)~= 0xFF then
			Enemies[count]=address
			count=count+1
			found=true
		end	
		if found then address=address+0x04
        else address=address+0x01
            if address >= 0xDC0 then
                break
            end
		end
	end
    return count
end

function printInfo()
    local count = updateEnemies()

    -- Print Enemy Info on Text Buffer
    enemyInfo:clear()
    enemyInfo:moveCursor(0, 0)
    enemyInfo:print("enemy: " .. tostring(count-1))
    for i=1, count+1 do
        local offset = Enemies[i]
        local ID = emu.memory.wram:read8(offset+0x85)
        local Xpos = tostring(emu.memory.wram:read8(offset+0x44))
        local Ypos = tostring(emu.memory.wram:read8(offset+0x48))
        local hp = tostring(emu.memory.wram:read8(offset+0x83) + emu.memory.wram:read8(offset+0x84)*256)

        local Name = enemyName[NAME_LANGUAGE][ID+1]

        enemyInfo:moveCursor(0, i)
        enemyInfo:print(string.format("%02X", ID) .. ": ")
        enemyInfo:moveCursor(4, i)
        enemyInfo:print(Name)
        enemyInfo:moveCursor(nameLength + 5, i)
        enemyInfo:print("X: " .. Xpos)
        enemyInfo:moveCursor(nameLength + 14, i)
        enemyInfo:print("Y: " .. Ypos)
        enemyInfo:moveCursor(nameLength + 29, i)
        enemyInfo:print("HP: " .. hp)
    end
end

-- Run function every frame
callbacks:add("frame", printInfo)