-- math functions
function math.decRound(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- script
local dumbassSin = 0

function createPost()
    set("UI.scoreTxt.size", 18)
    set("UI.scoreTxt.borderSize", 1.25)
    set("UI.timeIcon.visible", false)

    tweenObject("bfTween", "bf", {x = get("bf.x") + 300}, 10, "cubeIn", function()
        print("NO FORUCKING WYA")
    end)
end

local scoreDivider = " • "

function updatePost(delta)
    dumbassSin = dumbassSin + (delta * 2.5)
    for id = 0,3 do
        -- kinda weird ik but the engine wasn't really designed for lua so um
        local receptorList = "UI.playerStrums.receptors.members"
        set(receptorList.."["..id.."].y", _G["playerReceptorPosY"..id]+(math.sin(dumbassSin + id)*60))

        if arrowJustPressed(id) and not getOption("Botplay") then
            squash(id)
        end
    end

    local score = get("score")
    local accuracy = math.decRound(get("accuracy") * 100.0, 2)
    local misses = get("misses")
    local rank = get("rank")
    set("UI.scoreTxt.text", "Score: "..score..scoreDivider.."Accuracy: "..accuracy.."%"..scoreDivider.." Combo Breaks: "..misses..scoreDivider.."Rank: "..rank)
    set("UI.timeTxt.text", "- "..song.name.." ["..string.upper(song.difficulty).."] -")

    screenCenter("UI.scoreTxt", "X")
    screenCenter("UI.timeTxt", "X")
end

function onNoteHit(cancelled, time, direction, sus, mustPress)
    if mustPress then
        squash(direction)
    end
end

function squash(direction)
    local receptorList = "UI.playerStrums.receptors.members"
    local ogScale = get(receptorList.."["..direction.."].noteScale")
    set(receptorList.."["..direction.."].scale.x", ogScale * 2.5)
    set(receptorList.."["..direction.."].scale.y", ogScale * 0.1)
    tweenObject(
        "receptorSquish"..direction, 
        receptorList.."["..direction.."]", 
        {["scale.x"] = ogScale, ["scale.y"] = ogScale},
        0.2,
        "cubeOut"
    )
end