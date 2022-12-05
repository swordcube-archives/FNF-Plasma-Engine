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

    tweenObject("bfTween", "bf", {x = get("bf.x") + 300}, 10, "cubeIn", function()
        print("NO FORUCKING WYA")
    end)
end

local scoreDivider = " • "

function updatePost(delta)
    dumbassSin = dumbassSin + (delta * 2.5)
    for id = 0,3 do
        -- lengthy ik but the engine wasn't really designed for lua so um
        set("UI.playerStrums.receptors.members["..id.."].y", _G["playerReceptorPosY"..id]+(math.sin(dumbassSin + id)*30))
    end

    local score = get("score")
    local accuracy = math.decRound(get("accuracy") * 100.0, 2)
    local misses = get("misses")
    local rank = get("rank")
    set("UI.scoreTxt.text", "Score: "..score..scoreDivider.."Accuracy: "..accuracy.."%"..scoreDivider.." Combo Breaks: "..misses..scoreDivider.."Rank: "..rank)
    screenCenter("UI.scoreTxt", "X")
end

function onPlayerHit()

end