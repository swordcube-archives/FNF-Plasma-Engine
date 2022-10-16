function create()
    setDefaultCamZoom(0.9)

    makeSprite("back", -600, -200)
    loadGraphic("back", stageImage("stageback"))
    setProperty('back.scale.x', 1.1)
    setProperty('back.scale.y', 1.1)
    setProperty('back.scrollFactor.x', 0.9)
    setProperty('back.scrollFactor.y', 0.9)
    updateHitbox("back")
    addSprite("back")

    makeSprite("front", -650, 600)
    loadGraphic("front", stageImage("stagefront"))
    setProperty('front.scale.x', 1.1)
    setProperty('front.scale.y', 1.1)
    setProperty('front.scrollFactor.x', 0.9)
    setProperty('front.scrollFactor.y', 0.9)
    updateHitbox("front")
    addSprite("front")

    -- lights
    makeSprite("light1", -125, -100)
    loadGraphic("light1", stageImage("stage_light"))
    setProperty('light1.scale.x', 1.1)
    setProperty('light1.scale.y', 1.1)
    setProperty('light1.scrollFactor.x', 0.9)
    setProperty('light1.scrollFactor.y', 0.9)
    updateHitbox("light1")
    addSprite("light1")

    makeSprite("light2", 1225, -100)
    loadGraphic("light2", stageImage("stage_light"))
    setProperty('light2.scale.x', 1.1)
    setProperty('light2.scale.y', 1.1)
    setProperty('light2.scrollFactor.x', 0.9)
    setProperty('light2.scrollFactor.y', 0.9)
    setProperty('light2.flipX', true)
    updateHitbox("light2")
    addSprite("light2")

    -- curtains
    makeSprite("curtains", -500, -300)
    loadGraphic("curtains", stageImage("stagecurtains"))
    setProperty('curtains.scale.x', 0.9)
    setProperty('curtains.scale.y', 0.9)
    setProperty('curtains.scrollFactor.x', 1.3)
    setProperty('curtains.scrollFactor.y', 1.3)
    updateHitbox("curtains")
    addSprite("curtains")
end

function stageImage(p)
    return "stages/stage/"..p
end